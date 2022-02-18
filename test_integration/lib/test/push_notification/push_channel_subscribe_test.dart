import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';

Future<Map<String, dynamic>> testPushNotificationChannelSubscribe({
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

  final restPushChannel = rest.channels.get(TestConstants.pushChannelname);
  await restPushChannel.push.subscribeClient();

  final realtimePushChannel =
      realtime.channels.get(TestConstants.pushChannelname);
  await realtimePushChannel.push.subscribeClient();

  return {
    'restPushChannelHandle': await restPushChannel.handle,
    'realtimePushChannelHandle': await realtimePushChannel.handle,
  };
}
