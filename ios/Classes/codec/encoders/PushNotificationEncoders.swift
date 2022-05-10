import Ably
import Foundation
import UserNotifications

public class PushNotificationEncoders: NSObject {

    @objc
    public static let encodeDeviceDetails: (ARTDeviceDetails) -> Dictionary<String, Any> = { device in
        [
            TxDeviceDetails_id: device.id,
            TxDeviceDetails_clientId: device.clientId as Any,
            TxDeviceDetails_platform: device.platform,
            TxDeviceDetails_formFactor: device.formFactor,
            TxDeviceDetails_metadata: device.metadata,
            TxDeviceDetails_devicePushDetails: encodeDevicePushDetails(device.push)
        ];
    }
    
    @objc
    public static let encodeDevicePushDetails: (ARTDevicePushDetails) -> Dictionary<String, Any> = { devicePushDetails in
        [
            TxDevicePushDetails_recipient: devicePushDetails.recipient,
            TxDevicePushDetails_state: devicePushDetails.state as Any,
            TxDevicePushDetails_errorReason: (devicePushDetails.errorReason != nil ? Encoders.encodeErrorInfo(devicePushDetails.errorReason!) : nil) as Any
        ];
    }
    
    @objc
    public static let encodeLocalDevice: (ARTLocalDevice) -> Dictionary<String, Any> = { device in
        [
            TxLocalDevice_deviceSecret: device.secret as Any,
            TxLocalDevice_deviceIdentityToken: device.identityTokenDetails?.token as Any,
            // Fields inherited from DeviceDetails:
            TxDeviceDetails_id: device.id,
            TxDeviceDetails_clientId: device.clientId as Any,
            TxDeviceDetails_platform: device.platform,
            TxDeviceDetails_formFactor: device.formFactor,
            TxDeviceDetails_metadata: device.metadata,
            TxDeviceDetails_devicePushDetails: encodeDevicePushDetails(device.push)
        ];
    }
    
    @objc
    public static let encodePushChannelSubscription: (ARTPushChannelSubscription) -> Dictionary<String, Any> = { subscription in
        [
            TxPushChannelSubscription_channel: subscription.channel,
            TxPushChannelSubscription_clientId: subscription.clientId as Any,
            TxPushChannelSubscription_deviceId: subscription.deviceId as Any
        ];
    }
    
    @objc
    public static let encodeUNNotificationSettings: (UNNotificationSettings) -> Dictionary<String, Any> = { settings in
        var dictionary = Dictionary<String, Any>();
        
        dictionary[TxUNNotificationSettings_authorizationStatus] = settings.authorizationStatus.toString();
        dictionary[TxUNNotificationSettings_lockScreenSetting] = settings.lockScreenSetting.toString();
        dictionary[TxUNNotificationSettings_carPlaySetting] = settings.carPlaySetting.toString();
        dictionary[TxUNNotificationSettings_alertSetting] = settings.alertSetting.toString();
        dictionary[TxUNNotificationSettings_badgeSetting] = settings.badgeSetting.toString();
        dictionary[TxUNNotificationSettings_soundSetting] = settings.soundSetting.toString();
        
        dictionary[TxUNNotificationSettings_notificationCenterSetting] = settings.notificationCenterSetting.toString();
        
        dictionary[TxUNNotificationSettings_alertStyle] = settings.alertStyle.toString();
        if #available(iOS 11.0, *) {
            dictionary[TxUNNotificationSettings_showPreviewsSetting] = settings.showPreviewsSetting.toString()
        }
        if #available(iOS 12.0, *) {
            dictionary[TxUNNotificationSettings_providesAppNotificationSettings] = settings.providesAppNotificationSettings
            dictionary[TxUNNotificationSettings_criticalAlertSetting] = settings.criticalAlertSetting.toString();
        }
        if #available(iOS 13.0, *) {
            dictionary[TxUNNotificationSettings_announcementSetting] = settings.announcementSetting.toString()
        }
        if #available(iOS 15.0, *) {
           dictionary[TxUNNotificationSettings_scheduledDeliverySetting] = settings.scheduledDeliverySetting.toString()
        }
        
        return dictionary;
    }
    
    @objc
    public static let encodeRemoteMessage: (RemoteMessage) -> Dictionary<String, Any> = { remoteMessage in
        var dictionary = Dictionary<String, Any>();
        
        dictionary[TxRemoteMessage_data] = remoteMessage.data;
        dictionary[TxRemoteMessage_notification] = remoteMessage.notification?.toDictionary();
        
        return dictionary;
    }
}

extension Notification {
    func toDictionary() -> Dictionary<String, String?> {
        return [
            TxNotification_title: title,
            TxNotification_body: body,
        ]
    }
}

extension UNAuthorizationStatus {
    func toString() -> String {
        switch (self) {
        case .notDetermined:
            return TxUNAuthorizationStatusEnum_notDetermined;
        case .denied:
            return TxUNAuthorizationStatusEnum_denied;
        case .authorized:
            return TxUNAuthorizationStatusEnum_authorized;
        case .provisional:
            return TxUNAuthorizationStatusEnum_provisional;
        case .ephemeral:
            return TxUNAuthorizationStatusEnum_ephemeral;
        @unknown default:
            fatalError("Unsupported value in \(self).")
        }
    }
}

extension UNNotificationSetting {
    func toString() -> String {
        switch (self) {
        case .notSupported:
            return TxUNNotificationSettingEnum_notSupported
        case .disabled:
            return TxUNNotificationSettingEnum_disabled
        case .enabled:
            return TxUNNotificationSettingEnum_enabled
        @unknown default:
            fatalError("Unsupported value in \(self).")
        }
    }
}

extension UNAlertStyle {
    func toString() -> String {
        switch (self) {
        case .banner:
            return TxUNAlertStyleEnum_banner
        case .none:
            return TxUNAlertStyleEnum_none
        case .alert:
            return TxUNAlertStyleEnum_alert
        @unknown default:
            fatalError("Unsupported value in \(self).")
        }
    }
}

@available(iOS 11.0, *)
extension UNShowPreviewsSetting {
    func toString() -> String {
        switch (self) {
        case .always:
            return TxUNShowPreviewsSettingEnum_always
        case .never:
            return TxUNShowPreviewsSettingEnum_never
        case .whenAuthenticated:
            return TxUNShowPreviewsSettingEnum_whenAuthenticated
        @unknown default:
            fatalError("Unsupported value in \(self).")
        }
    }
}
