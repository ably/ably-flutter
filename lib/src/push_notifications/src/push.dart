/// Class providing push notification functionality
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1
abstract class Push {
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
  /// - iosProvisionalPermissionRequest (iOS only): Send notifications on a
  /// trial basis, by delaying the permission request until the
  /// user first sees the first notification. This is works on iOS12+.
  /// The notification is first delivered quietly, and the user will
  /// get an option to deliver it more prominently.
  ///
  /// For more information,
  /// see [Use Provisional Authorization to Send Trial Notifications](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc)
  Future<bool> requestNotificationPermission(
      {bool provisionalPermissionRequest = false});

  /// Deactivate this device for push notifications by removing
  /// the registration with the push transport such as FCM/APNS.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH2b
  ///
  /// On some platforms, this returns a deviceId (String), but the feature
  /// spec doesn't mention this.
  Future<void> deactivate();
}
