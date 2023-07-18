//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

package io.ably.flutter.plugin.generated;


final public class PlatformConstants {

    static final public class CodecTypes {
        public static final byte ablyMessage = (byte) 128;
        public static final byte ablyEventMessage = (byte) 129;
        public static final byte clientOptions = (byte) 130;
        public static final byte authOptions = (byte) 131;
        public static final byte messageData = (byte) 132;
        public static final byte messageExtras = (byte) 133;
        public static final byte message = (byte) 134;
        public static final byte tokenParams = (byte) 135;
        public static final byte tokenDetails = (byte) 136;
        public static final byte tokenRequest = (byte) 137;
        public static final byte restChannelOptions = (byte) 138;
        public static final byte realtimeChannelOptions = (byte) 139;
        public static final byte paginatedResult = (byte) 140;
        public static final byte restHistoryParams = (byte) 141;
        public static final byte realtimeHistoryParams = (byte) 142;
        public static final byte restPresenceParams = (byte) 143;
        public static final byte presenceMessage = (byte) 144;
        public static final byte realtimePresenceParams = (byte) 145;
        public static final byte deviceDetails = (byte) 146;
        public static final byte localDevice = (byte) 147;
        public static final byte pushChannelSubscription = (byte) 148;
        public static final byte unNotificationSettings = (byte) 149;
        public static final byte remoteMessage = (byte) 150;
        public static final byte errorInfo = (byte) 151;
        public static final byte logLevel = (byte) 152;
        public static final byte connectionStateChange = (byte) 153;
        public static final byte channelStateChange = (byte) 154;
        public static final byte cipherParams = (byte) 155;
    }

    static final public class PlatformMethod {
        public static final String getPlatformVersion = "getPlatformVersion";
        public static final String getVersion = "getVersion";
        public static final String resetAblyClients = "resetAblyClients";
        public static final String authCallback = "authCallback";
        public static final String realtimeAuthCallback = "realtimeAuthCallback";
        public static final String createRest = "createRest";
        public static final String setRestChannelOptions = "setRestChannelOptions";
        public static final String publish = "publish";
        public static final String restHistory = "restHistory";
        public static final String restPresenceGet = "restPresenceGet";
        public static final String restPresenceHistory = "restPresenceHistory";
        public static final String releaseRestChannel = "releaseRestChannel";
        public static final String restAuthAuthorize = "restAuthAuthorize";
        public static final String restAuthCreateTokenRequest = "restAuthCreateTokenRequest";
        public static final String restAuthRequestToken = "restAuthRequestToken";
        public static final String restAuthGetClientId = "restAuthGetClientId";
        public static final String createRealtime = "createRealtime";
        public static final String connectRealtime = "connectRealtime";
        public static final String closeRealtime = "closeRealtime";
        public static final String attachRealtimeChannel = "attachRealtimeChannel";
        public static final String detachRealtimeChannel = "detachRealtimeChannel";
        public static final String setRealtimeChannelOptions = "setRealtimeChannelOptions";
        public static final String realtimePresenceGet = "realtimePresenceGet";
        public static final String realtimePresenceHistory = "realtimePresenceHistory";
        public static final String realtimePresenceEnter = "realtimePresenceEnter";
        public static final String realtimePresenceUpdate = "realtimePresenceUpdate";
        public static final String realtimePresenceLeave = "realtimePresenceLeave";
        public static final String onRealtimePresenceMessage = "onRealtimePresenceMessage";
        public static final String publishRealtimeChannelMessage = "publishRealtimeChannelMessage";
        public static final String releaseRealtimeChannel = "releaseRealtimeChannel";
        public static final String realtimeHistory = "realtimeHistory";
        public static final String realtimeTime = "realtimeTime";
        public static final String restTime = "restTime";
        public static final String realtimeAuthAuthorize = "realtimeAuthAuthorize";
        public static final String realtimeAuthCreateTokenRequest = "realtimeAuthCreateTokenRequest";
        public static final String realtimeAuthRequestToken = "realtimeAuthRequestToken";
        public static final String realtimeAuthGetClientId = "realtimeAuthGetClientId";
        public static final String pushActivate = "pushActivate";
        public static final String pushDeactivate = "pushDeactivate";
        public static final String pushReset = "pushReset";
        public static final String pushSubscribeDevice = "pushSubscribeDevice";
        public static final String pushUnsubscribeDevice = "pushUnsubscribeDevice";
        public static final String pushSubscribeClient = "pushSubscribeClient";
        public static final String pushUnsubscribeClient = "pushUnsubscribeClient";
        public static final String pushListSubscriptions = "pushListSubscriptions";
        public static final String pushDevice = "pushDevice";
        public static final String pushRequestPermission = "pushRequestPermission";
        public static final String pushGetNotificationSettings = "pushGetNotificationSettings";
        public static final String pushOpenSettingsFor = "pushOpenSettingsFor";
        public static final String pushOnActivate = "pushOnActivate";
        public static final String pushOnDeactivate = "pushOnDeactivate";
        public static final String pushOnUpdateFailed = "pushOnUpdateFailed";
        public static final String pushNotificationTapLaunchedAppFromTerminated = "pushNotificationTapLaunchedAppFromTerminated";
        public static final String pushOnShowNotificationInForeground = "pushOnShowNotificationInForeground";
        public static final String pushOnMessage = "pushOnMessage";
        public static final String pushOnBackgroundMessage = "pushOnBackgroundMessage";
        public static final String pushOnNotificationTap = "pushOnNotificationTap";
        public static final String pushBackgroundFlutterApplicationReadyOnAndroid = "pushBackgroundFlutterApplicationReadyOnAndroid";
        public static final String onRealtimeConnectionStateChanged = "onRealtimeConnectionStateChanged";
        public static final String onRealtimeChannelStateChanged = "onRealtimeChannelStateChanged";
        public static final String onRealtimeChannelMessage = "onRealtimeChannelMessage";
        public static final String nextPage = "nextPage";
        public static final String firstPage = "firstPage";
        public static final String cryptoGetParams = "cryptoGetParams";
        public static final String cryptoGenerateRandomKey = "cryptoGenerateRandomKey";
    }

    static final public class TxTransportKeys {
        public static final String channelName = "channelName";
        public static final String params = "params";
        public static final String data = "data";
        public static final String clientId = "clientId";
        public static final String options = "options";
        public static final String messages = "messages";
    }

    static final public class TxAblyMessage {
        public static final String registrationHandle = "registrationHandle";
        public static final String type = "type";
        public static final String message = "message";
    }

    static final public class TxAblyEventMessage {
        public static final String eventName = "eventName";
        public static final String type = "type";
        public static final String message = "message";
    }

    static final public class TxErrorInfo {
        public static final String code = "code";
        public static final String message = "message";
        public static final String statusCode = "statusCode";
        public static final String href = "href";
        public static final String requestId = "requestId";
        public static final String cause = "cause";
    }

    static final public class TxMessageData {
        public static final String data = "data";
        public static final String type = "type";
    }

    static final public class TxDeltaExtras {
        public static final String format = "format";
        public static final String from = "from";
    }

    static final public class TxMessageExtras {
        public static final String extras = "extras";
        public static final String delta = "delta";
    }

    static final public class TxClientOptions {
        public static final String authUrl = "authUrl";
        public static final String authMethod = "authMethod";
        public static final String key = "key";
        public static final String tokenDetails = "tokenDetails";
        public static final String authHeaders = "authHeaders";
        public static final String authParams = "authParams";
        public static final String queryTime = "queryTime";
        public static final String useTokenAuth = "useTokenAuth";
        public static final String hasAuthCallback = "hasAuthCallback";
        public static final String clientId = "clientId";
        public static final String logLevel = "logLevel";
        public static final String tls = "tls";
        public static final String restHost = "restHost";
        public static final String realtimeHost = "realtimeHost";
        public static final String port = "port";
        public static final String tlsPort = "tlsPort";
        public static final String autoConnect = "autoConnect";
        public static final String useBinaryProtocol = "useBinaryProtocol";
        public static final String queueMessages = "queueMessages";
        public static final String echoMessages = "echoMessages";
        public static final String recover = "recover";
        public static final String environment = "environment";
        public static final String idempotentRestPublishing = "idempotentRestPublishing";
        public static final String disconnectedRetryTimeout = "disconnectedRetryTimeout";
        public static final String suspendedRetryTimeout = "suspendedRetryTimeout";
        public static final String httpMaxRetryDuration = "httpMaxRetryDuration";
        public static final String httpOpenTimeout = "httpOpenTimeout";
        public static final String httpRequestTimeout = "httpRequestTimeout";
        public static final String httpMaxRetryCount = "httpMaxRetryCount";
        public static final String realtimeRequestTimeout = "realtimeRequestTimeout";
        public static final String fallbackHosts = "fallbackHosts";
        public static final String fallbackHostsUseDefault = "fallbackHostsUseDefault";
        public static final String fallbackRetryTimeout = "fallbackRetryTimeout";
        public static final String defaultTokenParams = "defaultTokenParams";
        public static final String channelRetryTimeout = "channelRetryTimeout";
        public static final String transportParams = "transportParams";
        public static final String dartVersion = "dartVersion";
    }

    static final public class TxRestChannelOptions {
        public static final String cipherParams = "cipherParams";
    }

    static final public class TxRealtimeChannelOptions {
        public static final String params = "params";
        public static final String modes = "modes";
        public static final String cipherParams = "cipherParams";
    }

    static final public class TxCipherParams {
        public static final String androidHandle = "androidHandle";
        public static final String iosAlgorithm = "iosAlgorithm";
        public static final String iosKey = "iosKey";
    }

    static final public class TxTokenDetails {
        public static final String token = "token";
        public static final String expires = "expires";
        public static final String issued = "issued";
        public static final String capability = "capability";
        public static final String clientId = "clientId";
    }

    static final public class TxAuthOptions {
        public static final String authCallback = "authCallback";
        public static final String authUrl = "authUrl";
        public static final String authMethod = "authMethod";
        public static final String key = "key";
        public static final String token = "token";
        public static final String tokenDetails = "tokenDetails";
        public static final String authHeaders = "authHeaders";
        public static final String authParams = "authParams";
        public static final String queryTime = "queryTime";
        public static final String useTokenAuth = "useTokenAuth";
    }

    static final public class TxTokenParams {
        public static final String capability = "capability";
        public static final String clientId = "clientId";
        public static final String nonce = "nonce";
        public static final String timestamp = "timestamp";
        public static final String ttl = "ttl";
    }

    static final public class TxTokenRequest {
        public static final String capability = "capability";
        public static final String clientId = "clientId";
        public static final String keyName = "keyName";
        public static final String mac = "mac";
        public static final String nonce = "nonce";
        public static final String timestamp = "timestamp";
        public static final String ttl = "ttl";
    }

    static final public class TxEnumConstants {
        public static final String initialized = "initialized";
        public static final String connecting = "connecting";
        public static final String connected = "connected";
        public static final String disconnected = "disconnected";
        public static final String attaching = "attaching";
        public static final String attached = "attached";
        public static final String detaching = "detaching";
        public static final String detached = "detached";
        public static final String suspended = "suspended";
        public static final String closing = "closing";
        public static final String closed = "closed";
        public static final String failed = "failed";
        public static final String absent = "absent";
        public static final String leave = "leave";
        public static final String enter = "enter";
        public static final String present = "present";
        public static final String update = "update";
        public static final String presence = "presence";
        public static final String publish = "publish";
        public static final String subscribe = "subscribe";
        public static final String presenceSubscribe = "presenceSubscribe";
    }

    static final public class TxFormFactorEnum {
        public static final String phone = "phone";
        public static final String tablet = "tablet";
        public static final String desktop = "desktop";
        public static final String tv = "tv";
        public static final String watch = "watch";
        public static final String car = "car";
        public static final String embedded = "embedded";
        public static final String other = "other";
    }

    static final public class TxLogLevelEnum {
        public static final String none = "none";
        public static final String verbose = "verbose";
        public static final String debug = "debug";
        public static final String info = "info";
        public static final String warn = "warn";
        public static final String error = "error";
    }

    static final public class TxDevicePlatformEnum {
        public static final String ios = "ios";
        public static final String android = "android";
        public static final String browser = "browser";
    }

    static final public class TxDevicePushStateEnum {
        public static final String active = "active";
        public static final String failing = "failing";
        public static final String failed = "failed";
    }

    static final public class TxConnectionStateChange {
        public static final String current = "current";
        public static final String previous = "previous";
        public static final String event = "event";
        public static final String retryIn = "retryIn";
        public static final String reason = "reason";
    }

    static final public class TxChannelStateChange {
        public static final String current = "current";
        public static final String previous = "previous";
        public static final String event = "event";
        public static final String resumed = "resumed";
        public static final String reason = "reason";
    }

    static final public class TxMessage {
        public static final String id = "id";
        public static final String timestamp = "timestamp";
        public static final String clientId = "clientId";
        public static final String connectionId = "connectionId";
        public static final String encoding = "encoding";
        public static final String data = "data";
        public static final String name = "name";
        public static final String extras = "extras";
    }

    static final public class TxPresenceMessage {
        public static final String id = "id";
        public static final String action = "action";
        public static final String clientId = "clientId";
        public static final String connectionId = "connectionId";
        public static final String data = "data";
        public static final String encoding = "encoding";
        public static final String extras = "extras";
        public static final String timestamp = "timestamp";
    }

    static final public class TxPaginatedResult {
        public static final String items = "items";
        public static final String type = "type";
        public static final String hasNext = "hasNext";
    }

    static final public class TxRestHistoryParams {
        public static final String start = "start";
        public static final String end = "end";
        public static final String direction = "direction";
        public static final String limit = "limit";
    }

    static final public class TxRealtimeHistoryParams {
        public static final String start = "start";
        public static final String end = "end";
        public static final String direction = "direction";
        public static final String limit = "limit";
        public static final String untilAttach = "untilAttach";
    }

    static final public class TxRestPresenceParams {
        public static final String limit = "limit";
        public static final String clientId = "clientId";
        public static final String connectionId = "connectionId";
    }

    static final public class TxRealtimePresenceParams {
        public static final String waitForSync = "waitForSync";
        public static final String clientId = "clientId";
        public static final String connectionId = "connectionId";
    }

    static final public class TxDeviceDetails {
        public static final String id = "id";
        public static final String clientId = "clientId";
        public static final String platform = "platform";
        public static final String formFactor = "formFactor";
        public static final String metadata = "metadata";
        public static final String devicePushDetails = "devicePushDetails";
    }

    static final public class TxDevicePushDetails {
        public static final String recipient = "recipient";
        public static final String state = "state";
        public static final String errorReason = "errorReason";
    }

    static final public class TxLocalDevice {
        public static final String deviceSecret = "deviceSecret";
        public static final String deviceIdentityToken = "deviceIdentityToken";
    }

    static final public class TxPushChannelSubscription {
        public static final String channel = "channel";
        public static final String deviceId = "deviceId";
        public static final String clientId = "clientId";
    }

    static final public class TxPushRequestPermission {
        public static final String badge = "badge";
        public static final String sound = "sound";
        public static final String alert = "alert";
        public static final String carPlay = "carPlay";
        public static final String criticalAlert = "criticalAlert";
        public static final String providesAppNotificationSettings = "providesAppNotificationSettings";
        public static final String provisional = "provisional";
        public static final String announcement = "announcement";
    }

    static final public class TxUNNotificationSettings {
        public static final String authorizationStatus = "authorizationStatus";
        public static final String soundSetting = "soundSetting";
        public static final String badgeSetting = "badgeSetting";
        public static final String alertSetting = "alertSetting";
        public static final String notificationCenterSetting = "notificationCenterSetting";
        public static final String lockScreenSetting = "lockScreenSetting";
        public static final String carPlaySetting = "carPlaySetting";
        public static final String alertStyle = "alertStyle";
        public static final String showPreviewsSetting = "showPreviewsSetting";
        public static final String criticalAlertSetting = "criticalAlertSetting";
        public static final String providesAppNotificationSettings = "providesAppNotificationSettings";
        public static final String announcementSetting = "announcementSetting";
        public static final String scheduledDeliverySetting = "scheduledDeliverySetting";
        public static final String timeSensitiveSetting = "timeSensitiveSetting";
    }

    static final public class TxUNNotificationSettingEnum {
        public static final String notSupported = "notSupported";
        public static final String disabled = "disabled";
        public static final String enabled = "enabled";
    }

    static final public class TxUNAlertStyleEnum {
        public static final String none = "none";
        public static final String banner = "banner";
        public static final String alert = "alert";
    }

    static final public class TxUNAuthorizationStatusEnum {
        public static final String notDetermined = "notDetermined";
        public static final String denied = "denied";
        public static final String authorized = "authorized";
        public static final String provisional = "provisional";
        public static final String ephemeral = "ephemeral";
    }

    static final public class TxUNShowPreviewsSettingEnum {
        public static final String always = "always";
        public static final String whenAuthenticated = "whenAuthenticated";
        public static final String never = "never";
    }

    static final public class TxRemoteMessage {
        public static final String data = "data";
        public static final String notification = "notification";
    }

    static final public class TxNotification {
        public static final String title = "title";
        public static final String body = "body";
    }

    static final public class TxCryptoGetParams {
        public static final String algorithm = "algorithm";
        public static final String key = "key";
    }

    static final public class TxCryptoGenerateRandomKey {
        public static final String keyLength = "keyLength";
    }

}
