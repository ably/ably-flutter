import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/encoders.dart';
import '../../utils/realtime.dart';

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
  String name,
  List<String> names,
}) async {
  final messages = <Map<String, dynamic>>[];
  final realtime = await _createRealtime(apiKey);
  final channel = realtime.channels.get(channelName);
  await channel.attach();
  final subscription =
      channel.subscribe(name: name, names: names).listen((message) {
    messages.add(encodeMessage(message));
  });
  await publishMessages(channel);
  await subscription.cancel();
  return messages;
}

Future<Map<String, dynamic>> testRealtimeSubscribe({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  final appKey = await provision('sandbox-');

  final allMessages = await _getAllMessages(appKey.toString(), 'test-all');
  final nameFiltered = await _getAllMessages(
    appKey.toString(),
    'test-name',
    name: 'name1',
  );
  final namesFiltered = await _getAllMessages(
    appKey.toString(),
    'test-name',
    names: ['name1', 'name2'],
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
    extras: MessageExtras({
      'push': [
        {'title': 'Testing'}
      ]
    }),
  ));
  await extrasSubscription.cancel();

  return {
    'all': allMessages,
    'filteredWithName': nameFiltered,
    'filteredWithNames': namesFiltered,
    'extrasMessages': extrasMessages,
  };
}
