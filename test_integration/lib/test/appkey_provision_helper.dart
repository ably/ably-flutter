import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _capabilitySpec = {
  '*': ['publish', 'subscribe', 'history', 'presence'],
};
const authURL = 'https://www.ably.io/ably-auth/token-request/demos';

// per: https://docs.ably.io/client-lib-development-guide/test-api/
final _appSpec = Map.unmodifiable({
  // API Keys & Capabilities.
  'keys': [
    {
      // The need to use jsonEncode here is a requirement of the
      // Sandbox Test API. The capability map has to be JSON encoded
      // as a string and then appropriately escaped in order for
      // presentation within a string value.
      'capability': jsonEncode(_capabilitySpec),
    },
  ],
});

const _requestHeaders = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

class AppKey {
  final String name;
  final String secret;
  final String _keyStr;

  AppKey(this.name, this.secret, this._keyStr);

  @override
  String toString() => _keyStr;
}

Future<Map> _provisionApp(final String environmentPrefix) async {
  final url = 'https://${environmentPrefix}rest.ably.io/apps';
  final body = jsonEncode(_appSpec);
  final response = await http.post(url, body: body, headers: _requestHeaders);
  if (response.statusCode != HttpStatus.created) {
    throw HttpException("Server didn't return success."
      ' Status: ${response.statusCode}');
  }
  return jsonDecode(response.body) as Map;
}

Future<AppKey> provision(String environmentPrefix) async {
  final result = await _provisionApp(environmentPrefix);
  final key = result['keys'][0];
  return AppKey(
    key['keyName'] as String,
    key['keySecret'] as String,
    key['keyStr'] as String,
  );
}

Future<Map<String, dynamic>> getTokenRequest() async {
  // NOTE: This doesn't work with sandbox. The URL can point to test-harness's
  // tokenRequest express server's `/auth` endpoint
  final r = await http.get(authURL);
  //ignore: avoid_print
  print('tokenRequest from tokenRequest server: ${r.body}');
  return Map.castFrom<dynamic, dynamic, String, dynamic>(
    jsonDecode(r.body) as Map);
}
