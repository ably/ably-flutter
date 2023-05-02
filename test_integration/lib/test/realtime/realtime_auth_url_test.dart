
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

//Make sure that creating realtime with authURL won't crash
Future<Map<String, dynamic>> testCreateRealtimeWithAuthUrl({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final clientOptionsForToken = ClientOptions(
    key: appKey,
    environment: 'sandbox',
    logLevel: LogLevel.verbose,
  );

  final ablyForToken = Rest(
    options: clientOptionsForToken,
  );
  final accessToken = await ablyForToken.auth.requestToken();

  final Map<String, String> headers = {
    HttpHeaders.authorizationHeader: "Bearer $accessToken",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.acceptLanguageHeader: "ios",
  };
  final options = ClientOptions(
    authUrl: 'https://auth.ably.io/auth',
    authHeaders: headers,
    echoMessages: false,
  );
  final realtime = Realtime(options: options);
  realtime.connection.on().listen((stateChange) {
    print("Ably connection state changed: ${stateChange.event}");
  });
  return {'handle': await realtime.handle};
}
