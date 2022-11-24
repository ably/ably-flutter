import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// Notification sent by APNS or FCM
///
/// See https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/RemoteMessage.Notification
/// See https://developer.apple.com/documentation/usernotifications/unnotificationcontent
@immutable
class Notification {
  /// Title of a notification, comes from 'UNNotificationContent.title' on iOS
  /// and 'RemoteMessage.notification.title' on Android.
  final String title;

  /// Body of a notification, comes from 'UNNotificationContent.body' on iOS
  /// and 'RemoteMessage.notification.body' on Android.
  final String? body;

  /// @nodoc
  /// Initializes an instance without any defaults.
  const Notification({
    required this.title,
    this.body,
  });

  /// @nodoc
  /// Creates an instance from the map.
  factory Notification.fromMap(Map<String, dynamic> map) => Notification(
        body: map[TxNotification.body] as String?,
        title: map[TxNotification.title] as String,
      );
}
