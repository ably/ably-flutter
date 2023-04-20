import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testRealtimeRequestToken({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  //init ably for token
  final clientOptionsForToken = ClientOptions(
    key: appKey,
    environment: 'sandbox',
    logLevel: LogLevel.verbose,
  );

  final realtime = Realtime(
    options: clientOptionsForToken,
  );

  await realtime.auth?.requestToken();

  return {'handle': await realtime.handle};
}
