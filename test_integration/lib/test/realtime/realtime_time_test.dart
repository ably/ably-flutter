import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testRealtimeTime({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();
  final logMessages = <List<String?>>[];

  final realtime = Realtime(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose,
  );

  final realtimeTime = await realtime.time();

  return {
    'handle': await realtime.handle,
    'time': realtimeTime.toIso8601String(),
  };
}
