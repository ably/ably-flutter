import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';

Future<Map<String, dynamic>> testPushNotificationChannelSubscriptionList({
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
  final restDevice = await rest.device();
  await restPushChannel.push.subscribeDevice();
  await restPushChannel.push.subscribeClient();
  final restSubscriptionsByDeviceId = await restPushChannel.push
      .listSubscriptions({'deviceId': restDevice.id!});
  final restSubscriptionsByClientId =
      await restPushChannel.push.listSubscriptions({'clientId': clientId});

  final realtimePushChannel =
      realtime.channels.get(TestConstants.pushChannelname);
  final realtimeDevice = await realtime.device();
  await realtimePushChannel.push.subscribeDevice();
  final realtimeSubscriptionsByDeviceId = await realtimePushChannel.push
      .listSubscriptions({'deviceId': realtimeDevice.id!});
  final realtimeSubscriptionsByClientId =
      await realtimePushChannel.push.listSubscriptions({'clientId': clientId});

  return {
    'restPushChannelHandle': await restPushChannel.handle,
    'realtimePushChannelHandle': await realtimePushChannel.handle,
    'restDevice': restDevice,
    'realtimeDevice': realtimeDevice,
    'restSubscriptionsByDeviceId': restSubscriptionsByDeviceId,
    'restSubscriptionsByClientId': restSubscriptionsByClientId,
    'realtimeSubscriptionsByDeviceId': realtimeSubscriptionsByDeviceId,
    'realtimeSubscriptionsByClientId': realtimeSubscriptionsByClientId
  };
}
