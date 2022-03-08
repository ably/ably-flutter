import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimeEncryptedPublish({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RealtimeChannelOptions(cipherParams: cipherParams);

  final rest = Realtime(
      options: ClientOptions.fromKey(appKey.toString())
        ..environment = 'sandbox'
        ..clientId = 'someClientId');

  final channel = rest.channels.get('test');
  await channel.setOptions(channelOptions);

  await publishMessages(channel);
  return {
    'handle': await rest.handle,
  };
}
