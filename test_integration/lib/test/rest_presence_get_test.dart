import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../config/data.dart';
import '../config/encoders.dart';
import '../factory/reporter.dart';

final logMessages = <List<String>>[];

ClientOptions getClientOptions(
  String appKey, [
  String clientId = 'someClientId',
]) =>
    ClientOptions.fromKey(appKey)
      ..environment = 'sandbox'
      ..clientId = clientId
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]);

Future<Map<String, dynamic>> testRestPresenceGet({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  reporter.reportLog('init start');
  final appKey = (await provision('sandbox-')).toString();

  final rest = Rest(options: getClientOptions(appKey));
  final channel = rest.channels.get('test');
  final membersInitial = await _members(channel);

  // enter multiple clients
  for (var i = 0; i < messagesToPublish.length; i++) {
    await Realtime(
      options: getClientOptions(appKey, 'client-$i'),
    ).channels.get('test').presence.enter(messagesToPublish[i][1]);
  }

  await Future.delayed(const Duration(seconds: 2));

  final membersDefault = await _members(channel);
  await Future.delayed(const Duration(seconds: 2));

  final membersLimit4 = await _members(channel, RestPresenceParams(limit: 4));
  await Future.delayed(const Duration(seconds: 2));

  final membersLimit2 = await _members(channel, RestPresenceParams(limit: 2));
  await Future.delayed(const Duration(seconds: 2));

  final membersClientId = await _members(
    channel,
    RestPresenceParams(clientId: 'client-1'),
  );
  await Future.delayed(const Duration(seconds: 2));

  // TODO(tiholic) extract connection ID from realtime instance
  //  after implementing `id` update on connection object from platform
  // Until then, `membersConnectionId` will be empty list
  final membersConnectionId = await _members(
    channel,
    RestPresenceParams(connectionId: 'connection-1'),
  );
  await Future.delayed(const Duration(seconds: 2));

  return {
    'handle': await rest.handle,
    'membersInitial': membersInitial,
    'membersDefault': membersDefault,
    'membersLimit4': membersLimit4,
    'membersLimit2': membersLimit2,
    'membersClientId': membersClientId,
    'membersConnectionId': membersConnectionId,
    'log': logMessages,
  };
}

Future<List<Map<String, dynamic>>> _members(
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
