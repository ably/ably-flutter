//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

@import Foundation;

typedef NS_ENUM(UInt8, _Value) {
    ablyMessageCodecType = 128,
    ablyEventMessageCodecType = 129,
    clientOptionsCodecType = 130,
    messageDataCodecType = 131,
    messageExtrasCodecType = 132,
    messageCodecType = 133,
    tokenParamsCodecType = 134,
    tokenDetailsCodecType = 135,
    tokenRequestCodecType = 136,
    restChannelOptionsCodecType = 137,
    realtimeChannelOptionsCodecType = 138,
    paginatedResultCodecType = 139,
    restHistoryParamsCodecType = 140,
    realtimeHistoryParamsCodecType = 141,
    restPresenceParamsCodecType = 142,
    presenceMessageCodecType = 143,
    realtimePresenceParamsCodecType = 144,
    deviceDetailsCodecType = 145,
    localDeviceCodecType = 146,
    pushChannelSubscriptionCodecType = 147,
    unNotificationSettingsCodecType = 148,
    errorInfoCodecType = 149,
    connectionStateChangeCodecType = 150,
    channelStateChangeCodecType = 151,
};


// flutter platform channel method names
extern NSString *const AblyPlatformMethod_getPlatformVersion;
extern NSString *const AblyPlatformMethod_getVersion;
extern NSString *const AblyPlatformMethod_registerAbly;
extern NSString *const AblyPlatformMethod_authCallback;
extern NSString *const AblyPlatformMethod_realtimeAuthCallback;
extern NSString *const AblyPlatformMethod_createRestWithOptions;
extern NSString *const AblyPlatformMethod_setRestChannelOptions;
extern NSString *const AblyPlatformMethod_publish;
extern NSString *const AblyPlatformMethod_restHistory;
extern NSString *const AblyPlatformMethod_restPresenceGet;
extern NSString *const AblyPlatformMethod_restPresenceHistory;
extern NSString *const AblyPlatformMethod_releaseRestChannel;
extern NSString *const AblyPlatformMethod_createRealtimeWithOptions;
extern NSString *const AblyPlatformMethod_connectRealtime;
extern NSString *const AblyPlatformMethod_closeRealtime;
extern NSString *const AblyPlatformMethod_attachRealtimeChannel;
extern NSString *const AblyPlatformMethod_detachRealtimeChannel;
extern NSString *const AblyPlatformMethod_setRealtimeChannelOptions;
extern NSString *const AblyPlatformMethod_realtimePresenceGet;
extern NSString *const AblyPlatformMethod_realtimePresenceHistory;
extern NSString *const AblyPlatformMethod_realtimePresenceEnter;
extern NSString *const AblyPlatformMethod_realtimePresenceUpdate;
extern NSString *const AblyPlatformMethod_realtimePresenceLeave;
extern NSString *const AblyPlatformMethod_onRealtimePresenceMessage;
extern NSString *const AblyPlatformMethod_publishRealtimeChannelMessage;
extern NSString *const AblyPlatformMethod_releaseRealtimeChannel;
extern NSString *const AblyPlatformMethod_realtimeHistory;
extern NSString *const AblyPlatformMethod_pushActivate;
extern NSString *const AblyPlatformMethod_pushDeactivate;
extern NSString *const AblyPlatformMethod_pushSubscribeDevice;
extern NSString *const AblyPlatformMethod_pushUnsubscribeDevice;
extern NSString *const AblyPlatformMethod_pushSubscribeClient;
extern NSString *const AblyPlatformMethod_pushUnsubscribeClient;
extern NSString *const AblyPlatformMethod_pushListSubscriptions;
extern NSString *const AblyPlatformMethod_pushDevice;
extern NSString *const AblyPlatformMethod_pushRequestPermission;
extern NSString *const AblyPlatformMethod_pushGetNotificationSettings;
extern NSString *const AblyPlatformMethod_pushOpenSettingsForNotification;
extern NSString *const AblyPlatformMethod_onRealtimeConnectionStateChanged;
extern NSString *const AblyPlatformMethod_onRealtimeChannelStateChanged;
extern NSString *const AblyPlatformMethod_onRealtimeChannelMessage;
extern NSString *const AblyPlatformMethod_nextPage;
extern NSString *const AblyPlatformMethod_firstPage;

// key constants for TransportKeys
extern NSString *const TxTransportKeys_channelName;
extern NSString *const TxTransportKeys_params;
extern NSString *const TxTransportKeys_data;
extern NSString *const TxTransportKeys_clientId;
extern NSString *const TxTransportKeys_options;
extern NSString *const TxTransportKeys_messages;

// key constants for AblyMessage
extern NSString *const TxAblyMessage_registrationHandle;
extern NSString *const TxAblyMessage_type;
extern NSString *const TxAblyMessage_message;

// key constants for AblyEventMessage
extern NSString *const TxAblyEventMessage_eventName;
extern NSString *const TxAblyEventMessage_type;
extern NSString *const TxAblyEventMessage_message;

// key constants for ErrorInfo
extern NSString *const TxErrorInfo_code;
extern NSString *const TxErrorInfo_message;
extern NSString *const TxErrorInfo_statusCode;
extern NSString *const TxErrorInfo_href;
extern NSString *const TxErrorInfo_requestId;
extern NSString *const TxErrorInfo_cause;

// key constants for MessageData
extern NSString *const TxMessageData_data;
extern NSString *const TxMessageData_type;

// key constants for DeltaExtras
extern NSString *const TxDeltaExtras_format;
extern NSString *const TxDeltaExtras_from;

// key constants for MessageExtras
extern NSString *const TxMessageExtras_extras;
extern NSString *const TxMessageExtras_delta;

// key constants for ClientOptions
extern NSString *const TxClientOptions_authUrl;
extern NSString *const TxClientOptions_authMethod;
extern NSString *const TxClientOptions_key;
extern NSString *const TxClientOptions_tokenDetails;
extern NSString *const TxClientOptions_authHeaders;
extern NSString *const TxClientOptions_authParams;
extern NSString *const TxClientOptions_queryTime;
extern NSString *const TxClientOptions_useTokenAuth;
extern NSString *const TxClientOptions_hasAuthCallback;
extern NSString *const TxClientOptions_clientId;
extern NSString *const TxClientOptions_logLevel;
extern NSString *const TxClientOptions_tls;
extern NSString *const TxClientOptions_restHost;
extern NSString *const TxClientOptions_realtimeHost;
extern NSString *const TxClientOptions_port;
extern NSString *const TxClientOptions_tlsPort;
extern NSString *const TxClientOptions_autoConnect;
extern NSString *const TxClientOptions_useBinaryProtocol;
extern NSString *const TxClientOptions_queueMessages;
extern NSString *const TxClientOptions_echoMessages;
extern NSString *const TxClientOptions_recover;
extern NSString *const TxClientOptions_environment;
extern NSString *const TxClientOptions_idempotentRestPublishing;
extern NSString *const TxClientOptions_httpOpenTimeout;
extern NSString *const TxClientOptions_httpRequestTimeout;
extern NSString *const TxClientOptions_httpMaxRetryCount;
extern NSString *const TxClientOptions_realtimeRequestTimeout;
extern NSString *const TxClientOptions_fallbackHosts;
extern NSString *const TxClientOptions_fallbackHostsUseDefault;
extern NSString *const TxClientOptions_fallbackRetryTimeout;
extern NSString *const TxClientOptions_defaultTokenParams;
extern NSString *const TxClientOptions_channelRetryTimeout;
extern NSString *const TxClientOptions_transportParams;

// key constants for RestChannelOptions
extern NSString *const TxRestChannelOptions_cipher;

// key constants for RealtimeChannelOptions
extern NSString *const TxRealtimeChannelOptions_cipher;
extern NSString *const TxRealtimeChannelOptions_params;
extern NSString *const TxRealtimeChannelOptions_modes;

// key constants for TokenDetails
extern NSString *const TxTokenDetails_token;
extern NSString *const TxTokenDetails_expires;
extern NSString *const TxTokenDetails_issued;
extern NSString *const TxTokenDetails_capability;
extern NSString *const TxTokenDetails_clientId;

// key constants for TokenParams
extern NSString *const TxTokenParams_capability;
extern NSString *const TxTokenParams_clientId;
extern NSString *const TxTokenParams_nonce;
extern NSString *const TxTokenParams_timestamp;
extern NSString *const TxTokenParams_ttl;

// key constants for TokenRequest
extern NSString *const TxTokenRequest_capability;
extern NSString *const TxTokenRequest_clientId;
extern NSString *const TxTokenRequest_keyName;
extern NSString *const TxTokenRequest_mac;
extern NSString *const TxTokenRequest_nonce;
extern NSString *const TxTokenRequest_timestamp;
extern NSString *const TxTokenRequest_ttl;

// key constants for EnumConstants
extern NSString *const TxEnumConstants_initialized;
extern NSString *const TxEnumConstants_connecting;
extern NSString *const TxEnumConstants_connected;
extern NSString *const TxEnumConstants_disconnected;
extern NSString *const TxEnumConstants_attaching;
extern NSString *const TxEnumConstants_attached;
extern NSString *const TxEnumConstants_detaching;
extern NSString *const TxEnumConstants_detached;
extern NSString *const TxEnumConstants_suspended;
extern NSString *const TxEnumConstants_closing;
extern NSString *const TxEnumConstants_closed;
extern NSString *const TxEnumConstants_failed;
extern NSString *const TxEnumConstants_absent;
extern NSString *const TxEnumConstants_leave;
extern NSString *const TxEnumConstants_enter;
extern NSString *const TxEnumConstants_present;
extern NSString *const TxEnumConstants_update;
extern NSString *const TxEnumConstants_presence;
extern NSString *const TxEnumConstants_publish;
extern NSString *const TxEnumConstants_subscribe;
extern NSString *const TxEnumConstants_presenceSubscribe;

// key constants for FormFactorEnum
extern NSString *const TxFormFactorEnum_phone;
extern NSString *const TxFormFactorEnum_tablet;
extern NSString *const TxFormFactorEnum_desktop;
extern NSString *const TxFormFactorEnum_tv;
extern NSString *const TxFormFactorEnum_watch;
extern NSString *const TxFormFactorEnum_car;
extern NSString *const TxFormFactorEnum_embedded;
extern NSString *const TxFormFactorEnum_other;

// key constants for DevicePlatformEnum
extern NSString *const TxDevicePlatformEnum_ios;
extern NSString *const TxDevicePlatformEnum_android;
extern NSString *const TxDevicePlatformEnum_browser;

// key constants for DevicePushStateEnum
extern NSString *const TxDevicePushStateEnum_active;
extern NSString *const TxDevicePushStateEnum_failing;
extern NSString *const TxDevicePushStateEnum_failed;

// key constants for ConnectionStateChange
extern NSString *const TxConnectionStateChange_current;
extern NSString *const TxConnectionStateChange_previous;
extern NSString *const TxConnectionStateChange_event;
extern NSString *const TxConnectionStateChange_retryIn;
extern NSString *const TxConnectionStateChange_reason;

// key constants for ChannelStateChange
extern NSString *const TxChannelStateChange_current;
extern NSString *const TxChannelStateChange_previous;
extern NSString *const TxChannelStateChange_event;
extern NSString *const TxChannelStateChange_resumed;
extern NSString *const TxChannelStateChange_reason;

// key constants for Message
extern NSString *const TxMessage_id;
extern NSString *const TxMessage_timestamp;
extern NSString *const TxMessage_clientId;
extern NSString *const TxMessage_connectionId;
extern NSString *const TxMessage_encoding;
extern NSString *const TxMessage_data;
extern NSString *const TxMessage_name;
extern NSString *const TxMessage_extras;

// key constants for PresenceMessage
extern NSString *const TxPresenceMessage_id;
extern NSString *const TxPresenceMessage_action;
extern NSString *const TxPresenceMessage_clientId;
extern NSString *const TxPresenceMessage_connectionId;
extern NSString *const TxPresenceMessage_data;
extern NSString *const TxPresenceMessage_encoding;
extern NSString *const TxPresenceMessage_extras;
extern NSString *const TxPresenceMessage_timestamp;

// key constants for PaginatedResult
extern NSString *const TxPaginatedResult_items;
extern NSString *const TxPaginatedResult_type;
extern NSString *const TxPaginatedResult_hasNext;

// key constants for RestHistoryParams
extern NSString *const TxRestHistoryParams_start;
extern NSString *const TxRestHistoryParams_end;
extern NSString *const TxRestHistoryParams_direction;
extern NSString *const TxRestHistoryParams_limit;

// key constants for RealtimeHistoryParams
extern NSString *const TxRealtimeHistoryParams_start;
extern NSString *const TxRealtimeHistoryParams_end;
extern NSString *const TxRealtimeHistoryParams_direction;
extern NSString *const TxRealtimeHistoryParams_limit;
extern NSString *const TxRealtimeHistoryParams_untilAttach;

// key constants for RestPresenceParams
extern NSString *const TxRestPresenceParams_limit;
extern NSString *const TxRestPresenceParams_clientId;
extern NSString *const TxRestPresenceParams_connectionId;

// key constants for RealtimePresenceParams
extern NSString *const TxRealtimePresenceParams_waitForSync;
extern NSString *const TxRealtimePresenceParams_clientId;
extern NSString *const TxRealtimePresenceParams_connectionId;

// key constants for DeviceDetails
extern NSString *const TxDeviceDetails_id;
extern NSString *const TxDeviceDetails_clientId;
extern NSString *const TxDeviceDetails_platform;
extern NSString *const TxDeviceDetails_formFactor;
extern NSString *const TxDeviceDetails_metadata;
extern NSString *const TxDeviceDetails_devicePushDetails;

// key constants for DevicePushDetails
extern NSString *const TxDevicePushDetails_recipient;
extern NSString *const TxDevicePushDetails_state;
extern NSString *const TxDevicePushDetails_errorReason;

// key constants for LocalDevice
extern NSString *const TxLocalDevice_deviceSecret;
extern NSString *const TxLocalDevice_deviceIdentityToken;

// key constants for PushChannelSubscription
extern NSString *const TxPushChannelSubscription_channel;
extern NSString *const TxPushChannelSubscription_deviceId;
extern NSString *const TxPushChannelSubscription_clientId;

// key constants for PushRequestPermission
extern NSString *const TxPushRequestPermission_badge;
extern NSString *const TxPushRequestPermission_sound;
extern NSString *const TxPushRequestPermission_alert;
extern NSString *const TxPushRequestPermission_carPlay;
extern NSString *const TxPushRequestPermission_criticalAlert;
extern NSString *const TxPushRequestPermission_providesAppNotificationSettings;
extern NSString *const TxPushRequestPermission_provisional;
extern NSString *const TxPushRequestPermission_announcement;
extern NSString *const TxPushRequestPermission_none;

// key constants for UNNotificationSettings
extern NSString *const TxUNNotificationSettings_authorizationStatus;
extern NSString *const TxUNNotificationSettings_soundSetting;
extern NSString *const TxUNNotificationSettings_badgeSetting;
extern NSString *const TxUNNotificationSettings_alertSetting;
extern NSString *const TxUNNotificationSettings_notificationCenterSetting;
extern NSString *const TxUNNotificationSettings_lockScreenSetting;
extern NSString *const TxUNNotificationSettings_carPlaySetting;
extern NSString *const TxUNNotificationSettings_alertStyle;
extern NSString *const TxUNNotificationSettings_showPreviewsSetting;
extern NSString *const TxUNNotificationSettings_criticalAlertSetting;
extern NSString *const TxUNNotificationSettings_providesAppNotificationSettings;
extern NSString *const TxUNNotificationSettings_announcementSetting;
extern NSString *const TxUNNotificationSettings_scheduledDeliverySetting;
extern NSString *const TxUNNotificationSettings_timeSensitiveSetting;

// key constants for UNNotificationSettingEnum
extern NSString *const TxUNNotificationSettingEnum_notSupported;
extern NSString *const TxUNNotificationSettingEnum_disabled;
extern NSString *const TxUNNotificationSettingEnum_enabled;

// key constants for UNAlertStyleEnum
extern NSString *const TxUNAlertStyleEnum_none;
extern NSString *const TxUNAlertStyleEnum_banner;
extern NSString *const TxUNAlertStyleEnum_alert;

// key constants for UNAuthorizationStatusEnum
extern NSString *const TxUNAuthorizationStatusEnum_notDetermined;
extern NSString *const TxUNAuthorizationStatusEnum_denied;
extern NSString *const TxUNAuthorizationStatusEnum_authorized;
extern NSString *const TxUNAuthorizationStatusEnum_provisional;
extern NSString *const TxUNAuthorizationStatusEnum_ephemeral;

// key constants for UNShowPreviewsSettingEnum
extern NSString *const TxUNShowPreviewsSettingEnum_always;
extern NSString *const TxUNShowPreviewsSettingEnum_whenAuthenticated;
extern NSString *const TxUNShowPreviewsSettingEnum_never;
