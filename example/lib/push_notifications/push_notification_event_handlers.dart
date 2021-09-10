import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PushNotificationHandlers {
  static BuildContext? context;
  static final activationEvents = ably.Push.pushEvents;
  static final notificationEvents = ably.Push.notificationEvents;

  static void setUpEventHandlers() {
    activationEvents.onUpdateFailed.listen((error) async {
      print('onUpdateFailed error:');
      print(error);
    });
    // Optional
    activationEvents.onActivate.listen((error) async {
      print(error);
    });
    // Optional
    activationEvents.onDeactivate.listen((error) async {
      print(error);
    });
  }

  static void setUpMessageHandlers(
      ably.BackgroundMessageHandler backgroundMessageHandler) async {
    getLaunchMessage();

    notificationEvents.onBackgroundMessage = _backgroundMessageHandler;

    notificationEvents.onMessage.listen((remoteMessage) {
      print('Message was delivered to app while the app was in the foreground: '
          '$remoteMessage');
    });

    notificationEvents.onNotificationTap.listen((remoteMessage) {
      // TODO add another notification tap handler, for app in foreground?/ background.
      print('Notification was tapped while ..?: $remoteMessage');
    });
  }

  /**
   * You can get the notification which launched the app by a user tapping it.
   */
  static void getLaunchMessage() {
    PushNotificationHandlers
        .notificationEvents.notificationTapLaunchedAppFromTerminated
        .then((remoteMessage) {
      if (remoteMessage != null) {
        print('The app was launched by the user by tapping the notification');
        print(remoteMessage.data);
      }
    });
  }

  static Future<void> _backgroundMessageHandler(ably.RemoteMessage message) async {
    print('Just got a background message');
    // On Android, the notification for a data + notification message is shown
    // immediately after this method completes, or if it returns a Future, when it resolves.
    // On iOS,
    print(message);
  }
}
