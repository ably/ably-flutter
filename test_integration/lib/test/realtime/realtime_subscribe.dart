import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

Future<Realtime> _createRealtime(String apiKey) async {
  final realtime = Realtime(
    options: ClientOptions.fromKey(apiKey)
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..autoConnect = false,
  );
  await realtime.connect();
  return realtime;
}

Future<List<Map<String, dynamic>>> _getAllMessages(
  String apiKey,
  String channelName, {
  String? messageName,
  List<String>? messageNames,
}) async {
  final messages = <Map<String, dynamic>>[];
  final realtime = await _createRealtime(apiKey);
  final channel = realtime.channels.get(channelName);
  await channel.attach();
  final subscription = channel
      .subscribe(name: messageName, names: messageNames)
      .listen((message) {
    messages.add(encodeMessage(message));
  });
  await publishMessages(channel);
  await subscription.cancel();
  return messages;
}

Future<Map<String, dynamic>> testRealtimeSubscribe({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  final appKey = await AppProvisioning().provisionApp();

  final allMessages = await _getAllMessages(appKey.toString(), 'test-all');
  final nameFiltered = await _getAllMessages(
    appKey.toString(),
    'test-name',
    messageName: 'name1',
  );
  final namesFiltered = await _getAllMessages(
    appKey.toString(),
    'test-name',
    messageNames: ['name1', 'name2'],
  );

  final realtime = await _createRealtime(appKey.toString());
  final extrasChannel = realtime.channels.get('pushenabled:test:extras');
  await extrasChannel.attach();
  final extrasMessages = <Map<String, dynamic>>[];
  final extrasSubscription = extrasChannel.subscribe().listen((message) {
    extrasMessages.add(encodeMessage(message));
  });
  await extrasChannel.publish(
    message: Message(
      name: 'name',
      data: 'data',
      extras: const MessageExtras({...pushPayload}),
    ),
  );
  await Future.delayed(const Duration(seconds: 2));
  await extrasSubscription.cancel();

  return {
    'all': allMessages,
    'filteredWithName': nameFiltered,
    'filteredWithNames': namesFiltered,
    'extrasMessages': extrasMessages,
  };
}
