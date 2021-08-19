/// This file contains push notification types specific to iOS.

/// AuthorizationStatus
///
/// This exists so we can inform the user what authorization status the
/// iOS application on a device is currently in.
/// To see what it means to have a certain [UNAuthorizationStatus], read https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus
enum UNAuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
  ephemeral
}

enum UNAlertStyle { none, banner, alert }

/// UNNotificationSettingEnum
///
/// https://developer.apple.com/documentation/usernotifications/unnotificationsetting
enum UNNotificationSetting { notSupported, disabled, enabled }

enum UNShowPreviewsSetting { always, whenAuthenticated, never }

class UNNotificationSettings {
  UNAuthorizationStatus authorizationStatus;
  UNNotificationSetting soundSetting;
  UNNotificationSetting badgeSetting;
  UNNotificationSetting alertSetting;
  UNNotificationSetting notificationCenterSetting;
  UNNotificationSetting lockScreenSetting;
  UNNotificationSetting carPlaySetting;
  UNAlertStyle alertStyle;
  UNShowPreviewsSetting showPreviewsSetting;
  UNNotificationSetting criticalAlertSetting;
  bool providesAppNotificationSettings;
  UNNotificationSetting announcementSetting;

  UNNotificationSettings(
      {required this.authorizationStatus,
      required this.soundSetting,
      required this.badgeSetting,
      required this.alertSetting,
      required this.notificationCenterSetting,
      required this.lockScreenSetting,
      required this.carPlaySetting,
      required this.alertStyle,
      required this.showPreviewsSetting,
      required this.criticalAlertSetting,
      required this.providesAppNotificationSettings,
      required this.announcementSetting});
}
