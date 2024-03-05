import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/data.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';

final logMessages = <List<String?>>[];

List<Map<String, dynamic>> _encode(List<PresenceMessage> messages) =>
    encodeList<PresenceMessage>(messages, encodePresenceMessage);

Future<Map<String, dynamic>> testRealtimePresenceSubscribe({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();
  final presence = Realtime(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  ).channels.get('test').presence;

  final allMessages = <PresenceMessage>[];
  final allMessagesSubscription = presence.subscribe().listen(allMessages.add);

  final enterMessages = <PresenceMessage>[];
  final enterMessagesSubscription = presence
      .subscribe(action: PresenceAction.enter)
      .listen(enterMessages.add);

  final enterUpdateMessages = <PresenceMessage>[];
  final enterUpdateMessagesSubscription = presence.subscribe(actions: [
    PresenceAction.enter,
    PresenceAction.update
  ]).listen(enterUpdateMessages.add);

  final partialMessages = <PresenceMessage>[];
  final partialMessagesSubscription =
      presence.subscribe().listen(partialMessages.add);

  // enter-update-leave sequence with different data types to check if
  // data received by listeners is intact
  await presence.enter(messagesToPublish.first[1]);
  for (var i = 1; i < messagesToPublish.length - 1; i++) {
    await presence.update(messagesToPublish[i][1]);
  }

  // Wait for the update event as it is asynchronously triggered.
  // Then cancelling partial subscription expecting it to not receive
  // further presence events.
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  await partialMessagesSubscription.cancel();

  await presence.leave(messagesToPublish.last[1]);

  // Wait for the leave event to be received by listeners.
  // Assuming, they'd turn out in 2 seconds.
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  await allMessagesSubscription.cancel();
  await enterMessagesSubscription.cancel();
  await enterUpdateMessagesSubscription.cancel();

  return {
    'allMessages': _encode(allMessages),
    'enterMessages': _encode(enterMessages),
    'enterUpdateMessages': _encode(enterUpdateMessages),
    'partialMessages': _encode(partialMessages),
    'log': logMessages,
  };
}
