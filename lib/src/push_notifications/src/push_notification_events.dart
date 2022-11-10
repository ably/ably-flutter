import 'dart:ui';

import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED DOCSTRING
/// Type definition for a callback invoked when background push message
/// is received
/// END EDITED DOCSTRING
typedef BackgroundMessageHandler = void Function(RemoteMessage message);

/// BEGIN EDITED DOCSTRING
/// Push Notification events, such as message arriving or notification tap.
/// END EDITED DOCSTRING
abstract class PushNotificationEvents {
  /// BEGIN EDITED DOCSTRING
  /// Whether notifications are shown when the app is in the foreground.
  /// By default, no notifications are shown when the app is in the foreground.
  ///
  /// On messages with notifications trigger this method
  ///
  /// On iOS, the result will be passed to
  /// `userNotificationCenter:willPresentNotification` to decide how to show
  /// the notification while the app is in the foreground
  ///
  /// On Android, notifications will not be shown in the foreground. To create
  /// notifications while the app is in the foreground, manually create one
  /// when a [onMessage] or [BackgroundMessageHandler] is called.
  /// END EDITED DOCSTRING
  void setOnShowNotificationInForeground(
      Future<bool> Function(RemoteMessage message) callback);

  /// BEGIN EDITED DOCSTRING
  /// A stream that emmits messages while the app is in the foreground.
  /// END EDITED DOCSTRING
  Stream<RemoteMessage> get onMessage;

  /// BEGIN EDITED DOCSTRING
  /// A method that allows you to set a callback that's called whenever a
  /// notification or a data message is received by the device
  /// END EDITED DOCSTRING
  void setOnBackgroundMessage(BackgroundMessageHandler handler);

  /// BEGIN EDITED DOCSTRING
  /// A stream that emmits a message whenever a notification is tapped while the
  /// app is already in the foreground or in the background
  /// END EDITED DOCSTRING
  Stream<RemoteMessage> get onNotificationTap;

  /// BEGIN EDITED DOCSTRING
  /// A method that allows you to set a callback that's called whenever a user
  /// visits the "In-app settings":
  /// iOS Settings > App Name > Notifications > "Customize in App"
  ///
  /// iOS only: Specifically when [`userNotificationCenter(_:openSettingsFor:)`](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/2981869-usernotificationcenter)
  /// is called.
  /// END EDITED DOCSTRING
  void setOnOpenSettings(VoidCallback callback);

  /// BEGIN EDITED DOCSTRING
  /// Future resolves to a notification that was tapped and caused the app
  /// to launch from from a terminated state.
  /// Returns `null` if app was not launched from a notification.
  /// END EDITED DOCSTRING
  Future<RemoteMessage?> get notificationTapLaunchedAppFromTerminated;
}
