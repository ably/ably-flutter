import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../config/data.dart';
import '../config/encoders.dart';
import '../test_dispatcher.dart';

final logMessages = <List<String>>[];

Future<Map<String, dynamic>> testRealtimePresenceSubscribe({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  dispatcher.reportLog('init start');
  final appKey = (await provision('sandbox-')).toString();
  final presence = Realtime(
    options: ClientOptions.fromKey(appKey)
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]),
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
  await Future.delayed(const Duration(seconds: 2));
  await partialMessagesSubscription.cancel();

  await presence.leave(messagesToPublish.last[1]);

  // Wait for the leave event to be received by listeners.
  // Assuming, they'd turn out in 2 seconds.
  await Future.delayed(const Duration(seconds: 2));
  await allMessagesSubscription.cancel();
  await enterMessagesSubscription.cancel();
  await enterUpdateMessagesSubscription.cancel();

  return {
    'allMessages': encode(allMessages),
    'enterMessages': encode(enterMessages),
    'enterUpdateMessages': encode(enterUpdateMessages),
    'partialMessages': encode(partialMessages),
    'log': logMessages,
  };
}

List<Map<String, dynamic>> encode(List<PresenceMessage> messages) =>
    encodeList<PresenceMessage>(messages, encodePresenceMessage);
