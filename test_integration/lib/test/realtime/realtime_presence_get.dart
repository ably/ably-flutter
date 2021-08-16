import 'package:ably_flutter/ably_flutter.dart';

import '../../config/test_constants.dart';
import '../../factory/reporter.dart';
import '../../provisioning.dart';
import '../../utils/data.dart';
import '../../utils/realtime.dart';

final logMessages = <List<String?>>[];

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

Future<Map<String, dynamic>> testRealtimePresenceGet({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = (await provision('sandbox-')).toString();

  final realtime = Realtime(options: getClientOptions(appKey));
  final channel = realtime.channels.get('test');
  final membersInitial = await getPresenceMembers(channel);

  // enter multiple clients
  for (var i = 0; i < messagesToPublish.length; i++) {
    await Realtime(
      options: getClientOptions(appKey, 'client-$i'),
    ).channels.get('test').presence.enter(messagesToPublish[i][1]);
  }

  await Future.delayed(TestConstants.publishToHistoryDelay);

  final membersDefault = await getPresenceMembers(channel);
  await Future.delayed(TestConstants.publishToHistoryDelay);

  final membersClientId = await getPresenceMembers(
    channel,
    RealtimePresenceParams(clientId: 'client-1'),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  // TODO(tiholic) extract connection ID from realtime instance
  //  after implementing `id` update on connection object from platform
  // Until then, `membersConnectionId` will be empty list
  final membersConnectionId = await getPresenceMembers(
    channel,
    RealtimePresenceParams(connectionId: 'connection-1'),
  );
  await Future.delayed(TestConstants.publishToHistoryDelay);

  return {
    'handle': await realtime.handle,
    'membersInitial': membersInitial,
    'membersDefault': membersDefault,
    'membersClientId': membersClientId,
    'membersConnectionId': membersConnectionId,
    'log': logMessages,
  };
}
