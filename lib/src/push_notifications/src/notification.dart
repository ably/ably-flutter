import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Notification sent by APNS or FCM
///
/// See https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/RemoteMessage.Notification
/// See https://developer.apple.com/documentation/usernotifications/unnotificationcontent
/// END LEGACY DOCSTRING

/// BEGIN EDITED DOCSTRING
/// Notification sent by APNS or FCM
///
/// See https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/RemoteMessage.Notification
/// See https://developer.apple.com/documentation/usernotifications/unnotificationcontent
/// END EDITED DOCSTRING
@immutable
class Notification {
  /// BEGIN LEGACY DOCSTRING
  /// Title of notification, comes from 'UNNotificationContent.title' on iOS
  /// and 'RemoteMessage.notification.title' on Android
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED DOCSTRING
  /// Title of a notification, comes from 'UNNotificationContent.title' on iOS
  /// and 'RemoteMessage.notification.title' on Android
  /// END EDITED DOCSTRING
  final String title;

  /// BEGIN LEGACY DOCSTRING
  /// Title of notification, comes from 'UNNotificationContent.body' on iOS
  /// and 'RemoteMessage.notification.body' on Android
  /// END LEGACY DOCSTRING

  /// BEGIN LEGACY DOCSTRING
  /// Body of a notification, comes from 'UNNotificationContent.body' on iOS
  /// and 'RemoteMessage.notification.body' on Android
  /// END LEGACY DOCSTRING
  final String? body;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Initializes an instance without any defaults
  /// END LEGACY DOCSTRING
  const Notification({
    required this.title,
    this.body,
  });

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Creates an instance from the map
  /// END LEGACY DOCSTRING
  factory Notification.fromMap(Map<String, dynamic> map) => Notification(
        body: map[TxNotification.body] as String?,
        title: map[TxNotification.title] as String,
      );
}
