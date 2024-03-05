import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

Future<Map<String, dynamic>> testRestPublish({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();
  final logMessages = <List<String?>>[];

  final rest = Rest(
    options: ClientOptions(
      key: appKey.toString(),
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  );
  await publishMessages(rest.channels.get('test'));
  return {
    'handle': await rest.handle,
    'log': logMessages,
  };
}

Future<Map<String, dynamic>> testRestPublishSpec({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final appKey = await AppProvisioning().provisionApp();

  final rest = Rest(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  );
  final channel = rest.channels.get('test');
  await channel.publish();
  await channel.publish(name: 'name1');
  await channel.publish(data: 'data1');
  await channel.publish(name: 'name1', data: 'data1');
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  await channel.publish(
    message: Message(name: 'message-name1', data: 'message-data1'),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  await channel.publish(messages: [
    Message(name: 'messages-name1', data: 'messages-data1'),
    Message(name: 'messages-name2', data: 'messages-data2'),
  ]);
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  await channel.publish(
    message: Message(
      name: 'message-name1',
      data: 'message-data1',
      clientId: 'someClientId',
    ),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  // publishing message with a different client id
  Map<String, dynamic>? exception;
  try {
    await channel.publish(
        message: Message(name: 'name', clientId: 'client-id'));
  } on AblyException catch (e) {
    exception = encodeAblyException(e);
  }
  final history = await getHistory(
    channel,
    RestHistoryParams(direction: 'forwards'),
  );

  // client options - no client id, message has client id
  final rest2 = Rest(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
    ),
  );

  final channel2 = rest2.channels.get('test2');
  await channel2.publish(
    message: Message(name: 'name-client-id', clientId: 'client-id'),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  final history2 = await getHistory(
    channel2,
    RestHistoryParams(direction: 'forwards'),
  );

  // publish max allowed length - sandbox apps message limit is 16384
  Map<String, dynamic>? exception2;
  try {
    await channel2.publish(data: getRandomString(16384));
  } on AblyException catch (e) {
    exception2 = encodeAblyException(e);
  }

  // publish more than max allowed length
  Map<String, dynamic>? exception3;
  try {
    await channel2.publish(data: getRandomString(16384 + 1));
  } on AblyException catch (e) {
    exception3 = encodeAblyException(e);
  }

  final channel3 = rest2.channels.get('©Äblý');
  await channel3.publish(name: 'Ωπ', data: 'ΨΔ');

  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  final history3 = await getHistory(channel3);

  final channelExtras = rest.channels.get('pushenabled:test:extras');
  await channelExtras.publish(
    message: Message(
      name: 'name',
      data: 'data',
      extras: const MessageExtras({...pushPayload}),
    ),
  );
  final historyExtras = await getHistory(channelExtras);

  return {
    'handle': await rest.handle,
    'publishedMessages': history,
    'publishedMessages2': history2,
    'publishedMessages3': history3,
    'publishedExtras': historyExtras,
    'exception': exception,
    'exception2': exception2,
    'exception3': exception3,
  };
}
