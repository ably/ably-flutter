import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

final logMessages = <List<String?>>[];

ClientOptions getClientOptions(
  String appKey, [
  String clientId = 'someClientId',
]) =>
    ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: clientId,
      logLevel: LogLevel.error,
    );

Future<Map<String, dynamic>> testRealtimePresenceGet({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final realtime = Realtime(options: getClientOptions(appKey));
  final channel = realtime.channels.get('test');
  final membersInitial = await getPresenceMembers(channel);

  // enter multiple clients
  for (var i = 0; i < messagesToPublish.length; i++) {
    await Realtime(
      options: getClientOptions(appKey, 'client-$i'),
    ).channels.get('test').presence.enter(messagesToPublish[i][1]);
  }

  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final membersDefault = await getPresenceMembers(channel);
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final membersClientId = await getPresenceMembers(
    channel,
    const RealtimePresenceParams(clientId: 'client-1'),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  // TODO(tiholic) extract connection ID from realtime instance
  //  after implementing `id` update on connection object from platform
  // Until then, `membersConnectionId` will be empty list
  final membersConnectionId = await getPresenceMembers(
    channel,
    const RealtimePresenceParams(connectionId: 'connection-1'),
  );
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  return {
    'handle': await realtime.handle,
    'membersInitial': membersInitial,
    'membersDefault': membersDefault,
    'membersClientId': membersClientId,
    'membersConnectionId': membersConnectionId,
    'log': logMessages,
  };
}
