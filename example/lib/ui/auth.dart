import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

String _tokenDetailsURL(String keyName, [String prefix = '']) =>
    'https://${prefix}rest.ably.io/keys/$keyName/requestToken';

/// A user should never use an api key to create token details locally, this
/// function is used in this example app to avoid having a token
/// authentication server
Future<Map<String, dynamic>> getTokenDetails(
  String keyName,
  String keySecret, [
  String prefix = '',
]) async {
  final stringToBase64 = utf8.fuse(base64);
  final encoded = stringToBase64.encode('$keyName:$keySecret');
  final r = await const RetryOptions(
    maxAttempts: 5,
    delayFactor: Duration(seconds: 2),
  ).retry(() => http.post(
        Uri.parse(_tokenDetailsURL(keyName, prefix)),
        headers: {
          'Authorization': 'Basic $encoded',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'keyName': keyName,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      ));
  print('tokenDetails from server: ${r.body}');
  return Map.castFrom<dynamic, dynamic, String, dynamic>(
    jsonDecode(r.body) as Map,
  );
}
