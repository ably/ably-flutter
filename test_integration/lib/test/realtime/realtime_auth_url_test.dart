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
    logLevel: LogLevel.verbose,
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
      logLevel: LogLevel.verbose);
  final realtime = Realtime(options: options);
  var connected = false;
  realtime.connection.on().listen((stateChange) {
    if (stateChange.event == ConnectionEvent.connected) {
      connected = true;
    }
  });
  await realtime.connect();
  await Future<void>.delayed(const Duration(seconds: 5));
  if (!connected) {
    throw Error();
  }
  return {'handle': await realtime.handle};
}
