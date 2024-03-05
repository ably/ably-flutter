import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimePublish({
  Reporter? reporter,
  Map<String, dynamic>? payload,
}) async {
  final appKey = await AppProvisioning().provisionApp();
  final logMessages = <List<String?>>[];

  final realtime = Realtime(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  );
  await publishMessages(realtime.channels.get('test'));
  await realtime.close();
  return {
    'handle': await realtime.handle,
    'log': logMessages,
  };
}

Future<Map<String, dynamic>> testRealtimePublishSpec({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final appKey = await AppProvisioning().provisionApp();

  final realtime = Realtime(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  );
  final channel = realtime.channels.get('test');
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
    RealtimeHistoryParams(direction: 'forwards'),
  );

  // client options - no client id, message has client id
  final realtime2 = Realtime(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
    ),
  );

  final channel2 = realtime2.channels.get('test2');
  await channel2.publish(
    message: Message(name: 'name-client-id', clientId: 'client-id'),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  final history2 = await getHistory(
    channel2,
    RealtimeHistoryParams(direction: 'forwards'),
  );

  final channel3 = realtime2.channels.get('©Äblý');
  await channel3.publish(name: 'Ωπ', data: 'ΨΔ');

  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  final history3 = await getHistory(channel3);

  final channelExtras = realtime.channels.get('pushenabled:test:extras');
  await channelExtras.publish(
    message: Message(
      name: 'name',
      data: 'data',
      extras: const MessageExtras({...pushPayload}),
    ),
  );
  final historyExtras = await getHistory(channelExtras);

  return {
    'handle': await realtime.handle,
    'publishedMessages': history,
    'publishedMessages2': history2,
    'publishedMessages3': history3,
    'publishedExtras': historyExtras,
    'exception': exception,
  };
}
