import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';

Future<Map<String, dynamic>> testPushNotificationDeactivation({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final appKey = await provision('sandbox-');
  const environment = 'sandbox';
  const clientId = 'someClientId';

  final rest = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = environment
      ..clientId = clientId,
  );

  final realtime = Realtime(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = environment
      ..clientId = clientId,
  );

  final restPush = Push(rest: rest);
  await restPush.deactivate();

  final realtimePush = Push(realtime: realtime);
  await realtimePush.deactivate();

  return {
    'restPushHandle': await restPush.handle,
    'realtimePushHandle': await realtimePush.handle,
  };
}
