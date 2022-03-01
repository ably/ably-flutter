import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimeEncryptedPublish({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await provision('sandbox-');

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RealtimeChannelOptions(cipherParams: cipherParams);

  final realtime = Realtime(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId',
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
  final appKey = await provision('sandbox-');

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RealtimeChannelOptions(cipherParams: cipherParams);

  // Realtime instance where client id is specified in the instance itself
  final realtimeWithClientId = Realtime(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = clientId
      ..logLevel = LogLevel.verbose,
  );

  // Create encrypted  & plaintext channels with client ID
  final encryptedChannelWithClientId =
      realtimeWithClientId.channels.get('test');
  await encryptedChannelWithClientId.setOptions(channelOptions);
  final plaintextChannelWithClientId =
      realtimeWithClientId.channels.get('test');

  // Send simple message data
  await encryptedChannelWithClientId.publish();
  await encryptedChannelWithClientId.publish(name: 'name');
  await encryptedChannelWithClientId.publish(data: 'data');
  await encryptedChannelWithClientId.publish(name: 'name', data: 'data');
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Send single message object
  await encryptedChannelWithClientId.publish(
    message: Message(
      name: 'single-message-name',
      data: 'single-message-data',
    ),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Send multiple message objects at once
  await encryptedChannelWithClientId.publish(messages: [
    Message(name: 'multi-message-name-1', data: 'multi-message-data-1'),
    Message(name: 'multi-message-name-2', data: 'multi-message-data-2'),
  ]);
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Send message with [clientId] defined
  await encryptedChannelWithClientId.publish(
    message: Message(
      name: 'single-message-with-client-id-name',
      data: 'single-message-with-client-id-data',
      clientId: clientId,
    ),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Retrieve history of channels where client id was specified
  final historyOfEncryptedChannelWithClientId = await getHistory(
    encryptedChannelWithClientId,
    RealtimeHistoryParams(direction: 'forwards'),
  );
  final historyOfPlaintextChannelWithClientId = await getHistory(
    plaintextChannelWithClientId,
    RealtimeHistoryParams(direction: 'forwards'),
  );

  // Realtime instance where client id has to be specified in messages
  final realtimeWithoutClientId = Realtime(
    options: ClientOptions.fromKey(appKey.toString())..environment = 'sandbox',
  );

  // Create encrypted channel without client ID
  final encryptedChannelWithoutClientId =
      realtimeWithoutClientId.channels.get('test2');
  await encryptedChannelWithoutClientId.setOptions(channelOptions);
  final plaintextChannelWithoutClientId =
      realtimeWithoutClientId.channels.get('test2');

  // Send message with client ID provided
  await encryptedChannelWithoutClientId.publish(
    message: Message(
      name: 'single-message-with-client-id',
      clientId: clientId,
    ),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Retrieve history of channels where client id was not specified
  final historyOfEncryptedChannelWithoutClientId = await getHistory(
    encryptedChannelWithoutClientId,
    RealtimeHistoryParams(direction: 'forwards'),
  );
  final historyOfPlaintextChannelWithoutClientId = await getHistory(
    plaintextChannelWithoutClientId,
    RealtimeHistoryParams(direction: 'forwards'),
  );

  // Create encrypted channel with push capability
  final encryptedPushEnabledChannelWithClientId =
      realtimeWithClientId.channels.get('pushenabled:test:extras');
  await encryptedPushEnabledChannelWithClientId.setOptions(channelOptions);
  final plaintextPushEnabledChannelWithClientId =
      realtimeWithClientId.channels.get('pushenabled:test:extras');

  // Send message with extras to encrypted push-enabled channel
  await encryptedPushEnabledChannelWithClientId.publish(
    message: Message(
      name: 'single-message-push-enabled-name',
      data: 'single-message-push-enabled-data',
      extras: const MessageExtras({...pushPayload}),
    ),
  );

  // Retrieve history of push-enabled channels
  final historyOfEncryptedPushEnabledChannel =
      await getHistory(encryptedPushEnabledChannelWithClientId);
  final historyOfPlaintextPushEnabledChannel =
      await getHistory(plaintextPushEnabledChannelWithClientId);

  return {
    'handle': await realtimeWithClientId.handle,
    'historyOfEncryptedChannelWithClientId':
        historyOfEncryptedChannelWithClientId,
    'historyOfPlaintextChannelWithClientId':
        historyOfPlaintextChannelWithClientId,
    'historyOfEncryptedChannelWithoutClientId':
        historyOfEncryptedChannelWithoutClientId,
    'historyOfPlaintextChannelWithoutClientId':
        historyOfPlaintextChannelWithoutClientId,
    'historyOfEncryptedPushEnabledChannel':
        historyOfEncryptedPushEnabledChannel,
    'historyOfPlaintextPushEnabledChannel':
        historyOfPlaintextPushEnabledChannel,
  };
}
