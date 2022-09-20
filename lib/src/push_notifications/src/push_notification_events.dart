import 'dart:ui';

import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// type definition for a callback invoked when background push message
/// is received
/// END LEGACY DOCSTRING
typedef BackgroundMessageHandler = void Function(RemoteMessage message);

/// BEGIN LEGACY DOCSTRING
/// Push Notification events, such as message arriving or notification tap.
/// END LEGACY DOCSTRING
abstract class PushNotificationEvents {
  /// BEGIN LEGACY DOCSTRING
  /// Configure if notifications are shown when the app is in the foreground.
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
  /// END LEGACY DOCSTRING
  void setOnShowNotificationInForeground(
      Future<bool> Function(RemoteMessage message) callback);

  /// BEGIN LEGACY DOCSTRING
  /// The notification has not yet been tapped.
  /// END LEGACY DOCSTRING
  Stream<RemoteMessage> get onMessage;

  /// BEGIN LEGACY DOCSTRING
  /// This method will be called when a notification or data message is
  /// received by the device.
  /// END LEGACY DOCSTRING
  void setOnBackgroundMessage(BackgroundMessageHandler handler);

  /// BEGIN LEGACY DOCSTRING
  /// Called when notification is tapped while the app is already in the
  /// foreground or in the background
  /// END LEGACY DOCSTRING
  Stream<RemoteMessage> get onNotificationTap;

  /// BEGIN LEGACY DOCSTRING
  /// Called when the user visits the "In-app settings", such as when in the
  /// iOS Settings > App Name > Notifications > "Customize in App"
  ///
  /// iOS only: Specifically when [`userNotificationCenter(_:openSettingsFor:)`](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/2981869-usernotificationcenter)
  /// is called.
  /// END LEGACY DOCSTRING
  void setOnOpenSettings(VoidCallback callback);

  /// BEGIN LEGACY DOCSTRING
  /// Future resolves to the notification which was tapped to cause the app
  /// to launch from from a terminated state. `null` if app was not launched
  /// from a notification.
  /// END LEGACY DOCSTRING
  Future<RemoteMessage?> get notificationTapLaunchedAppFromTerminated;
}
