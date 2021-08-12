import 'package:ably_flutter/ably_flutter.dart';

import 'data.dart';
import 'encoders.dart';

Future<void> publishMessages(RealtimeChannel channel) async {
  for (final data in messagesToPublish) {
    await channel.publish(name: data[0] as String?, data: data[1]);
  }
}

Future<List<Map<String, dynamic>>> getHistory(
  RealtimeChannel channel, [
  RealtimeHistoryParams? params,
]) async {
  var results = await channel.history(params);
  final messages = encodeList<Message>(results.items, encodeMessage);
  while (results.hasNext()) {
    results = await results.next();
    messages.addAll(encodeList<Message>(results.items, encodeMessage));
  }
  return messages;
}

Future<List<Map<String, dynamic>>> getPresenceMembers(
  RealtimeChannel channel, [
  RealtimePresenceParams? params,
]) async =>
    encodeList<PresenceMessage>(
      await channel.presence.get(params),
      encodePresenceMessage,
    );

Future<List<Map<String, dynamic>>> getPresenceHistory(
  RealtimeChannel channel, [
  RealtimeHistoryParams? params,
]) async {
  var results = await channel.presence.history(params);
  final messages =
      encodeList<PresenceMessage>(results.items, encodePresenceMessage);
  while (results.hasNext()) {
    results = await results.next();
    messages.addAll(
      encodeList<PresenceMessage>(results.items, encodePresenceMessage),
    );
  }
  return messages;
}
