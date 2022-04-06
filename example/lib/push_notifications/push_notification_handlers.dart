import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../ui/utilities.dart';

class PushNotificationHandlers {
  static BuildContext? context;
  static final activationEvents = ably.Push.activationEvents;
  static final notificationEvents = ably.Push.notificationEvents;

  static BehaviorSubject<List<ably.RemoteMessage>>
      _receivedMessagesBehaviorSubject =
      BehaviorSubject<List<ably.RemoteMessage>>.seeded([]);
  static ValueStream<List<ably.RemoteMessage>> receivedMessagesStream =
      _receivedMessagesBehaviorSubject.stream;

  static void setUpEventHandlers() {
    activationEvents.onUpdateFailed.listen((error) async {
      logAndDisplayError(error,
          prefixMessage: 'Push update registration failed');
    });
    activationEvents.onActivate.listen((error) async {
      logAndDisplayError(error, prefixMessage: 'Push activation failed');
    });
    activationEvents.onDeactivate.listen((error) async {
      logAndDisplayError(error, prefixMessage: 'Push deactivation failed');
    });
  }

  static void setUpMessageHandlers() {
    getLaunchMessage();

    notificationEvents.setOnBackgroundMessage(_backgroundMessageHandler);

    notificationEvents.setOnOpenSettings(() {
      print('The iOS user has asked to see the In-app Notification Settings');
    });

    notificationEvents.onMessage.listen((message) {
      addMessage(message);
      print('RemoteMessage received while app is in foreground:\n'
          'RemoteMessage.Notification: ${message.notification}'
          'RemoteMessage.Data: ${message.data}');
    });

    notificationEvents.setOnShowNotificationInForeground((message) async {
      print(
          'Opting to show the notification when the app is in the foreground.');
      return true;
    });

    notificationEvents.onNotificationTap.listen((remoteMessage) {
      addMessage(remoteMessage);
      print('Notification was tapped: $remoteMessage');
    });
  }

  /// You can get the notification which launched the app by a user tapping it.
  static void getLaunchMessage() {
    notificationEvents.notificationTapLaunchedAppFromTerminated
        .then((remoteMessage) {
      if (remoteMessage != null) {
        addMessage(remoteMessage);
        print('The app was launched by the user by tapping the notification');
        print(remoteMessage.data);
      }
    });
  }

  static void clearReceivedMessages() {
    _receivedMessagesBehaviorSubject.add([]);
  }

  static Future<void> _backgroundMessageHandler(
      ably.RemoteMessage message) async {
    addMessage(message);
    print('RemoteMessage received while app is in background:\n'
        'RemoteMessage.Notification: ${message.notification}'
        'RemoteMessage.Data: ${message.data}');
  }

  static void addMessage(ably.RemoteMessage message) {
    final newList = List<ably.RemoteMessage>.from(receivedMessagesStream.value)
      ..add(message);
    _receivedMessagesBehaviorSubject.add(newList);
  }
}
