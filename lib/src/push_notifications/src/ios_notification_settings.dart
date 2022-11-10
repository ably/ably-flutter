// ignore_for_file: public_member_api_docs

import 'package:ably_flutter/ably_flutter.dart';

/// @nodoc
/// This file contains push notification types specific to iOS. All types begin
/// with "UN", since these types belong to the User Notifications framework
///
/// These types exist so we can use iOS specific notification APIs, such as
/// getting the current notification settings/ permissions the application has,
/// and requesting permissions.
///
/// UNAuthorizationStatus: Constants indicating whether the app is allowed to
/// schedule notifications.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus)
enum UNAuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
  ephemeral,
}

/// @nodoc
/// Constants indicating the presentation styles for alerts.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unalertstyle)
enum UNAlertStyle {
  none,
  banner,
  alert,
}

/// @nodoc
/// Constants that indicate the current status of a notification setting.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unnotificationsetting)
enum UNNotificationSetting {
  notSupported,
  disabled,
  enabled,
}

/// @nodoc
/// Constants indicating the style previewing a notification's content.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unshowpreviewssetting)
enum UNShowPreviewsSetting {
  always,
  whenAuthenticated,
  never,
}

/// @nodoc
/// The object for managing notification-related settings and the authorization
/// status of your app.
///
/// [Apple docs](https://developer.apple.com/documentation/usernotifications/unnotificationsettings)
class UNNotificationSettings {
  UNNotificationSetting alertSetting;
  UNAlertStyle alertStyle;
  UNNotificationSetting announcementSetting;
  UNAuthorizationStatus authorizationStatus;
  UNNotificationSetting badgeSetting;
  UNNotificationSetting carPlaySetting;
  UNNotificationSetting criticalAlertSetting;
  UNNotificationSetting lockScreenSetting;
  UNNotificationSetting notificationCenterSetting;
  bool providesAppNotificationSettings;
  UNNotificationSetting soundSetting;
  UNShowPreviewsSetting showPreviewsSetting;
  UNNotificationSetting scheduledDeliverySetting;

  /// @nodoc
  /// Users do not create this class. Call [Push.getNotificationSettings]
  /// instead.
  UNNotificationSettings({
    required this.alertSetting,
    required this.alertStyle,
    required this.announcementSetting,
    required this.authorizationStatus,
    required this.badgeSetting,
    required this.carPlaySetting,
    required this.criticalAlertSetting,
    required this.lockScreenSetting,
    required this.notificationCenterSetting,
    required this.providesAppNotificationSettings,
    required this.showPreviewsSetting,
    required this.soundSetting,
    required this.scheduledDeliverySetting,
  });
}
