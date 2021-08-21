import '../../platform/platform.dart';
import 'ios_notification_settings.dart';
import 'push_events.dart';

/// Class providing push notification functionality
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1
abstract class Push {
  /// An instance to access events related to push, such as device activation,
  /// deactivation and notification permissions.
  static PushEvents pushEvents = PushNative.pushEvents;

  /// Activate this device for push notifications by registering
  /// with the push transport such as GCM/APNS.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH2a
  Future<void> activate();

  /// Request permission from the user to show them notifications. This is
  /// required to show user notifications. Otherwise, notifications may
  /// silently get received by the application.
  ///
  /// This always returns true on Android, since you don't need permissions
  /// to show notifications to the user.
  ///
  /// Params:
  /// - badge: The ability to update the app’s badge.
  /// - sound: The ability to play sounds.
  /// - alert: The ability to display alerts.
  /// - carPlay: The ability to display notifications in a CarPlay environment.
  /// - criticalAlerts: The ability to play sounds for critical alerts.
  /// - providesAppNotificationSettings: An option indicating the system should
  ///     display a button for in-app notification settings.
  /// - provisional: Send notifications on a
  /// trial basis, by delaying the permission request until the
  /// user first sees the first notification. This is works on iOS12+.
  /// The notification is first delivered quietly, and the user will
  /// get an option to deliver it more prominently. If provisional is true,
  /// the permission request alert will not be shown to the user, regardless
  /// of other options passed in. For more information, see [Use Provisional Authorization to Send Trial Notifications](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc)
  /// - announcement: Only available on iOS 13+. Deprecated in iOS 15+, because
  ///   it is automatically/ always granted.
  ///
  /// [Apple docs](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649527-requestauthorization)
  Future<bool> requestPermission(
      {bool badge = true,
      bool sound = true,
      bool alert = true,
      bool carPlay = true,
      bool criticalAlert = false,
      bool provisional = false,
      bool providesAppNotificationSettings = false,
      bool announcement = true});

  /// Gets the iOS notification settings ([UNNotificationSettings]) for
  /// the application.
  ///
  /// [Apple docs](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649524-getnotificationsettings)
  Future<UNNotificationSettings> getNotificationSettings();

  /// Deactivate this device for push notifications by removing
  /// the registration with the push transport such as FCM/APNS.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH2b
  Future<void> deactivate();
}
