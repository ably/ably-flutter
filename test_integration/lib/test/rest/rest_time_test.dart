import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testRestTime({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();
  final logMessages = <List<String?>>[];

  final rest = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose,
  );

  final restTime = await rest.time();

  return {
    'handle': await rest.handle,
    'time': restTime.toIso8601String(),
  };
}
