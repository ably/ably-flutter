import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimePublish({
  Reporter? reporter,
  Map<String, dynamic>? payload,
}) async {
  final appKey = await AppProvisioning().provisionApp();
  final logMessages = <List<String?>>[];

  final realtime = Realtime(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose,
  );
  await publishMessages(realtime.channels.get('test'));
  await realtime.close();
  return {
    'handle': await realtime.handle,
    'log': logMessages,
  };
}
