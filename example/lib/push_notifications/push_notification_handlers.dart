import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/ui/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PushNotificationHandlers {
  static BuildContext? context;
  static final activationEvents = ably.Push.pushEvents;
  static final notificationEvents = ably.Push.notificationEvents;

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

    notificationEvents.onMessage.listen((remoteMessage) {
      print('Message was delivered to app while the app was in the foreground: '
          '$remoteMessage');
    });

    notificationEvents.setOnShowNotificationInForeground((message) async {
      print(
          'Opting to show the notification when the app is in the foreground.');
      return true;
    });

    notificationEvents.onNotificationTap.listen((remoteMessage) {
      print('Notification was tapped: $remoteMessage');
    });
  }

  /// You can get the notification which launched the app by a user tapping it.
  static void getLaunchMessage() {
    notificationEvents.notificationTapLaunchedAppFromTerminated
        .then((remoteMessage) {
      if (remoteMessage != null) {
        print('The app was launched by the user by tapping the notification');
        print(remoteMessage.data);
      }
    });
  }

  static Future<void> _backgroundMessageHandler(
      ably.RemoteMessage message) async {
    print('Just received a background message, with:');
    print('RemoteMessage.Notification: ${message.notification}');
    print('RemoteMessage.Data: ${message.data}');
  }
}
