import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/encoders.dart';
import '../../utils/realtime.dart';

Future<List<Map<String, dynamic>>> _getAllMessages(
  String apiKey,
  String channelName, {
  String name,
  List<String> names,
}) async {
  final messages = <Map<String, dynamic>>[];

  final realtime = Realtime(
    options: ClientOptions.fromKey(apiKey)
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..autoConnect = false,
  );
  await realtime.connect();

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

  return {
    'all': await _getAllMessages(appKey.toString(), 'test-all'),
    'filteredWithName':
        await _getAllMessages(appKey.toString(), 'test-name', name: 'name1'),
    'filteredWithNames': await _getAllMessages(appKey.toString(), 'test-name',
        names: ['name1', 'name2']),
  };
}
