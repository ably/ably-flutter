import 'package:ably_flutter/ably_flutter.dart';

import 'data.dart';
import 'encoders.dart';

Future<void> publishMessages(RestChannel channel) async {
  for (final data in messagesToPublish) {
    await channel.publish(name: data[0] as String, data: data[1]);
  }
}

Future<List<Map<String, dynamic>>> getHistory(
  RestChannel channel, [
  RestHistoryParams params,
]) async {
  var results = await channel.history(params);
  final messages = encodeList<Message>(results.items, encodeMessage);
  while (results.hasNext()) {
    results = await results.next();
    messages.addAll(encodeList<Message>(results.items, encodeMessage));
  }
  return messages;
}

Future<List<Map<String, dynamic>>> getPresenceHistory(
  RestChannel channel, [
  RestHistoryParams params,
]) async {
  var results = await channel.presence.history(params);
  final messages =
      encodeList<PresenceMessage>(results.items, encodePresenceMessage);
  while (results.hasNext()) {
    results = await results.next();
    messages.addAll(
        encodeList<PresenceMessage>(results.items, encodePresenceMessage));
  }
  return messages;
}

Future<List<Map<String, dynamic>>> getPresenceMembers(
  RestChannel channel, [
  RestPresenceParams params,
]) async {
  var results = await channel.presence.get(params);
  final messages =
      encodeList<PresenceMessage>(results.items, encodePresenceMessage);
  while (results.hasNext()) {
    results = await results.next();
    messages.addAll(
        encodeList<PresenceMessage>(results.items, encodePresenceMessage));
  }
  return messages;
}
