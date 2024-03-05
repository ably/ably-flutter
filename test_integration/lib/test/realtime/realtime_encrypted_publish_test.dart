import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
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

  final realtime = Realtime(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
    ),
  );

  final channel = realtime.channels.get('test');
  await channel.setOptions(channelOptions);

  await publishMessages(channel);
  return {
    'handle': await realtime.handle,
  };
}

Future<Map<String, dynamic>> testRealtimeEncryptedPublishSpec({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  const clientId = 'clientId';
  final appKey = await AppProvisioning().provisionApp();

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RealtimeChannelOptions(cipherParams: cipherParams);

  // Realtime instance where client id is specified in the instance itself
  final realtimeWithClientId = Realtime(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: clientId,
      logLevel: LogLevel.error,
    ),
  );

  // Create encrypted channel with client ID
  final encryptedChannel = realtimeWithClientId.channels.get('test');
  await encryptedChannel.setOptions(channelOptions);

  // Send simple message data
  await encryptedChannel.publish();
  await encryptedChannel.publish(name: 'name');
  await encryptedChannel.publish(data: 'data');
  await encryptedChannel.publish(name: 'name', data: 'data');
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  // Send single message object
  await encryptedChannel.publish(
    message: Message(
      name: 'single-message-name',
      data: 'single-message-data',
    ),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  // Send multiple message objects at once
  await encryptedChannel.publish(messages: [
    Message(name: 'multi-message-name-1', data: 'multi-message-data-1'),
    Message(name: 'multi-message-name-2', data: 'multi-message-data-2'),
  ]);
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  // Send message with [clientId] defined
  await encryptedChannel.publish(
    message: Message(
      name: 'single-message-with-client-id-name',
      data: 'single-message-with-client-id-data',
      clientId: clientId,
    ),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  // Retrieve history of channel where client id was specified
  final historyOfEncryptedChannel = await getHistory(
    encryptedChannel,
    RealtimeHistoryParams(direction: 'forwards'),
  );

  // Create encrypted channel with push capability
  final encryptedPushEnabledChannel =
      realtimeWithClientId.channels.get('pushenabled:test:extras');
  await encryptedPushEnabledChannel.setOptions(channelOptions);

  // Send message with extras to encrypted push-enabled channel
  await encryptedPushEnabledChannel.publish(
    message: Message(
      name: 'single-message-push-enabled-name',
      data: 'single-message-push-enabled-data',
      extras: const MessageExtras({...pushPayload}),
    ),
  );

  // Retrieve history of push-enabled channels
  final historyOfEncryptedPushEnabledChannel =
      await getHistory(encryptedPushEnabledChannel);

  // Retreive plaintext history of encrypted channel
  await encryptedChannel.setOptions(const RealtimeChannelOptions());
  final historyOfPlaintextChannel = await getHistory(
    encryptedChannel,
    RealtimeHistoryParams(direction: 'forwards'),
  );
  await encryptedPushEnabledChannel.setOptions(const RealtimeChannelOptions());
  final historyOfPlaintextPushEnabledChannel =
      await getHistory(encryptedPushEnabledChannel);

  return {
    'handle': await realtimeWithClientId.handle,
    'historyOfEncryptedChannel': historyOfEncryptedChannel,
    'historyOfPlaintextChannel': historyOfPlaintextChannel,
    'historyOfEncryptedPushEnabledChannel':
        historyOfEncryptedPushEnabledChannel,
    'historyOfPlaintextPushEnabledChannel':
        historyOfPlaintextPushEnabledChannel,
  };
}
