import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

Future<Map<String, dynamic>> testRestEncryptedPublish({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RestChannelOptions(cipherParams: cipherParams);

  final rest = Rest(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  );

  final channel = rest.channels.get('test');
  await channel.setOptions(channelOptions);

  await publishMessages(channel);
  return {
    'handle': await rest.handle,
  };
}

Future<Map<String, dynamic>> testRestEncryptedPublishSpec({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  const clientId = 'clientId';
  final appKey = await AppProvisioning().provisionApp();

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RestChannelOptions(cipherParams: cipherParams);

  // Rest instance where client id is specified in the instance itself
  final restWithClientId = Rest(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: clientId,
      logLevel: LogLevel.error,
    ),
  );

  // Create encrypted channel with client ID
  final encryptedChannel = restWithClientId.channels.get('test');
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
    RestHistoryParams(direction: 'forwards'),
  );

  // Create encrypted channel with push capability
  final encryptedPushEnabledChannel =
      restWithClientId.channels.get('pushenabled:test:extras');
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
  await encryptedChannel.setOptions(RestChannelOptions());
  final historyOfPlaintextChannel = await getHistory(
    encryptedChannel,
    RestHistoryParams(direction: 'forwards'),
  );
  await encryptedPushEnabledChannel.setOptions(RestChannelOptions());
  final historyOfPlaintextPushEnabledChannel =
      await getHistory(encryptedPushEnabledChannel);

  return {
    'handle': await restWithClientId.handle,
    'historyOfEncryptedChannel': historyOfEncryptedChannel,
    'historyOfPlaintextChannel': historyOfPlaintextChannel,
    'historyOfEncryptedPushEnabledChannel':
        historyOfEncryptedPushEnabledChannel,
    'historyOfPlaintextPushEnabledChannel':
        historyOfPlaintextPushEnabledChannel,
  };
}
