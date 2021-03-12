import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/encoders.dart';
import '../../utils/rest.dart';

Future<Map<String, dynamic>> testRestPublish({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await provision('sandbox-');
  final logMessages = <List<String>>[];

  final rest = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]),
  );
  await publishMessages(rest.channels.get('test'));
  return {
    'handle': await rest.handle,
    'log': logMessages,
  };
}

Future<Map<String, dynamic>> testRestPublishSpec({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  final appKey = await provision('sandbox-');

  final rest = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose,
  );
  final channel = rest.channels.get('test');
  await channel.publish();
  await channel.publish(name: 'name1');
  await channel.publish(data: 'data1');
  await channel.publish(name: 'name1', data: 'data1');
  await Future.delayed(const Duration(seconds: 2));
  await channel.publish(
    message: Message(name: 'message-name1', data: 'message-data1'),
  );
  await Future.delayed(const Duration(seconds: 2));
  await channel.publish(messages: [
    Message(name: 'messages-name1', data: 'messages-data1'),
    Message(name: 'messages-name2', data: 'messages-data2'),
  ]);
  await Future.delayed(const Duration(seconds: 2));
  await channel.publish(
    message: Message(
        name: 'message-name1', data: 'message-data1', clientId: 'someClientId'),
  );
  await Future.delayed(const Duration(seconds: 2));

  // publishing message with a different client id
  Map<String, dynamic> exception;
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
    options: ClientOptions.fromKey(appKey.toString())..environment = 'sandbox',
  );
  final channel2 = rest2.channels.get('test2');
  await channel2.publish(
    message: Message(name: 'name-client-id', clientId: 'client-id'),
  );
  await Future.delayed(const Duration(seconds: 2));
  final history2 = await getHistory(
    channel2,
    RestHistoryParams(direction: 'forwards'),
  );

  return {
    'handle': await rest.handle,
    'publishedMessages': history,
    'exception': exception,
    'publishedMessages2': history2,
  };
}
