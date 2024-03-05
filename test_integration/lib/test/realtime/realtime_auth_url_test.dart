import 'dart:async';
import 'dart:ffi';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

//Make sure that creating realtime with authUrk connects without a problem
Future<Map<String, dynamic>> testCreateRealtimeWithAuthUrl({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final clientOptionsForToken = ClientOptions(
    key: appKey,
    environment: 'sandbox',
    logLevel: LogLevel.error,
    fallbackHosts: <String>['a.ably-realtime.com', 'b.ably-realtime.com'],
  );

  final ablyForToken = Rest(
    options: clientOptionsForToken,
  );
  final tokenDetails = await ablyForToken.auth.requestToken();

  final authUrl =
      'https://echo.ably.io/?body=${Uri.encodeComponent(tokenDetails.token!)}';
  final options = ClientOptions(
      authUrl: authUrl,
      environment: 'sandbox',
      useTokenAuth: true,
      autoConnect: false,
      logLevel: LogLevel.error);
  final realtime = Realtime(options: options);
  final completer = Completer<void>();
  realtime.connection.on().listen((stateChange) {
    if (stateChange.current == ConnectionState.connected) {
      completer.complete();
    }
  });
  await realtime.connect();
  Future<Void> _onTimeout() {
    throw Error();
  }

  await completer.future
      .timeout(const Duration(seconds: 30), onTimeout: _onTimeout);

  return {'handle': await realtime.handle};
}
