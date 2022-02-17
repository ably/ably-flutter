import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';

Future<Map<String, dynamic>> testPushNotificationActivation({
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
  await restPush.activate();

  final realtimePush = Push(realtime: realtime);
  await realtimePush.activate();

  return {
    'restHandle': await rest.handle,
    'realtimeHandle': await realtime.handle,
  };
}
