import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/provisioning.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

Future<Map<String, dynamic>> testRestEncryptedPublish({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await provision('sandbox-');

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RestChannelOptions(cipherParams: cipherParams);

  final rest = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose,
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
  final appKey = await provision('sandbox-');

  final cipherParams =
      await Crypto.getDefaultParams(key: TestConstants.encryptedChannelKey);

  final channelOptions = RestChannelOptions(cipherParams: cipherParams);

  // Rest instance where client id is specified in the instance itself
  final restWithClientId = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = clientId
      ..logLevel = LogLevel.verbose,
  );

  final channelWithClientId = restWithClientId.channels.get('test');
  await channelWithClientId.setOptions(channelOptions);

  // Send simple message data
  await channelWithClientId.publish();
  await channelWithClientId.publish(name: 'name');
  await channelWithClientId.publish(data: 'data');
  await channelWithClientId.publish(name: 'name', data: 'data');
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Send single message object
  await channelWithClientId.publish(
    message: Message(
      name: 'single-message-name',
      data: 'single-message-data',
    ),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Send multiple message objects at once
  await channelWithClientId.publish(messages: [
    Message(name: 'multi-message-name-1', data: 'multi-message-data-1'),
    Message(name: 'multi-message-name-2', data: 'multi-message-data-2'),
  ]);
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Send message with [clientId] defined
  await channelWithClientId.publish(
    message: Message(
      name: 'single-message-with-client-id-name',
      data: 'single-message-with-client-id-data',
      clientId: clientId,
    ),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Retrieve history of encrypted channel where client id was specified
  final historyOfChannelWithClientId = await getHistory(
    channelWithClientId,
    RestHistoryParams(direction: 'forwards'),
  );

  // Rest instance where client id has to be specified in messages
  final restWithoutClientId = Rest(
    options: ClientOptions.fromKey(appKey.toString())..environment = 'sandbox',
  );

  // Send message with client ID provided
  final channelWithoutClientId = restWithoutClientId.channels.get('test2');
  await channelWithoutClientId.publish(
    message: Message(
      name: 'single-message-with-client-id',
      clientId: clientId,
    ),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // Retrieve history of encrypted channel where client id was not specified
  final historyOfChannelWithoutClientId = await getHistory(
    channelWithoutClientId,
    RestHistoryParams(direction: 'forwards'),
  );

  // Send message with extras to push-enabled channel
  final pushEnabledChannelWithClientId =
      restWithClientId.channels.get('pushenabled:test:extras');
  await pushEnabledChannelWithClientId.publish(
    message: Message(
      name: 'single-message-push-enabled-name',
      data: 'single-message-push-enabled-data',
      extras: const MessageExtras({...pushPayload}),
    ),
  );

  // Retrieve history of encrypted push-enabled channel
  final historyOfPushEnabledChannel =
      await getHistory(pushEnabledChannelWithClientId);

  return {
    'handle': await restWithClientId.handle,
    'historyOfChannelWithClientId': historyOfChannelWithClientId,
    'historyOfChannelWithoutClientId': historyOfChannelWithoutClientId,
    'historyOfPushEnabledChannel': historyOfPushEnabledChannel,
  };
}
