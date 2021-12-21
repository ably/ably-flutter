//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

package io.ably.flutter.plugin.generated;

public final class PlatformConstants {

  public static final class CodecTypes {
    public static final byte ablyMessage = (byte) 128;
    public static final byte ablyEventMessage = (byte) 129;
    public static final byte clientOptions = (byte) 130;
    public static final byte messageData = (byte) 131;
    public static final byte messageExtras = (byte) 132;
    public static final byte message = (byte) 133;
    public static final byte tokenParams = (byte) 134;
    public static final byte tokenDetails = (byte) 135;
    public static final byte tokenRequest = (byte) 136;
    public static final byte restChannelOptions = (byte) 137;
    public static final byte realtimeChannelOptions = (byte) 138;
    public static final byte paginatedResult = (byte) 139;
    public static final byte restHistoryParams = (byte) 140;
    public static final byte realtimeHistoryParams = (byte) 141;
    public static final byte restPresenceParams = (byte) 142;
    public static final byte presenceMessage = (byte) 143;
    public static final byte realtimePresenceParams = (byte) 144;
    public static final byte deviceDetails = (byte) 145;
    public static final byte localDevice = (byte) 146;
    public static final byte pushChannelSubscription = (byte) 147;
    public static final byte unNotificationSettings = (byte) 148;
    public static final byte remoteMessage = (byte) 149;
    public static final byte errorInfo = (byte) 150;
    public static final byte logLevel = (byte) 151;
    public static final byte connectionStateChange = (byte) 152;
    public static final byte channelStateChange = (byte) 153;
    public static final byte cipherParams = (byte) 154;
    public static final byte stats = (byte) 155;
  }

  public static final class PlatformMethod {
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
    public static final String stats = "stats";
    public static final String pushActivate = "pushActivate";
    public static final String pushDeactivate = "pushDeactivate";
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
    public static final String pushNotificationTapLaunchedAppFromTerminated =
        "pushNotificationTapLaunchedAppFromTerminated";
    public static final String pushOnShowNotificationInForeground =
        "pushOnShowNotificationInForeground";
    public static final String pushOnMessage = "pushOnMessage";
    public static final String pushOnBackgroundMessage = "pushOnBackgroundMessage";
    public static final String pushOnNotificationTap = "pushOnNotificationTap";
    public static final String pushBackgroundFlutterApplicationReadyOnAndroid =
        "pushBackgroundFlutterApplicationReadyOnAndroid";
    public static final String onRealtimeConnectionStateChanged =
        "onRealtimeConnectionStateChanged";
    public static final String onRealtimeChannelStateChanged = "onRealtimeChannelStateChanged";
    public static final String onRealtimeChannelMessage = "onRealtimeChannelMessage";
    public static final String nextPage = "nextPage";
    public static final String firstPage = "firstPage";
    public static final String cryptoGetParams = "cryptoGetParams";
    public static final String cryptoGenerateRandomKey = "cryptoGenerateRandomKey";
  }

  public static final class TxTransportKeys {
    public static final String channelName = "channelName";
    public static final String params = "params";
    public static final String data = "data";
    public static final String clientId = "clientId";
    public static final String options = "options";
    public static final String messages = "messages";
  }

  public static final class TxAblyMessage {
    public static final String registrationHandle = "registrationHandle";
    public static final String type = "type";
    public static final String message = "message";
  }

  public static final class TxAblyEventMessage {
    public static final String eventName = "eventName";
    public static final String type = "type";
    public static final String message = "message";
  }

  public static final class TxErrorInfo {
    public static final String code = "code";
    public static final String message = "message";
    public static final String statusCode = "statusCode";
    public static final String href = "href";
    public static final String requestId = "requestId";
    public static final String cause = "cause";
  }

  public static final class TxMessageData {
    public static final String data = "data";
    public static final String type = "type";
  }

  public static final class TxDeltaExtras {
    public static final String format = "format";
    public static final String from = "from";
  }

  public static final class TxMessageExtras {
    public static final String extras = "extras";
    public static final String delta = "delta";
  }

  public static final class TxClientOptions {
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
  }

  public static final class TxRestChannelOptions {
    public static final String cipherParams = "cipherParams";
  }

  public static final class TxRealtimeChannelOptions {
    public static final String params = "params";
    public static final String modes = "modes";
    public static final String cipherParams = "cipherParams";
  }

  public static final class TxCipherParams {
    public static final String androidHandle = "androidHandle";
    public static final String iosAlgorithm = "iosAlgorithm";
    public static final String iosKey = "iosKey";
  }

  public static final class TxTokenDetails {
    public static final String token = "token";
    public static final String expires = "expires";
    public static final String issued = "issued";
    public static final String capability = "capability";
    public static final String clientId = "clientId";
  }

  public static final class TxTokenParams {
    public static final String capability = "capability";
    public static final String clientId = "clientId";
    public static final String nonce = "nonce";
    public static final String timestamp = "timestamp";
    public static final String ttl = "ttl";
  }

  public static final class TxTokenRequest {
    public static final String capability = "capability";
    public static final String clientId = "clientId";
    public static final String keyName = "keyName";
    public static final String mac = "mac";
    public static final String nonce = "nonce";
    public static final String timestamp = "timestamp";
    public static final String ttl = "ttl";
  }

  public static final class TxEnumConstants {
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

  public static final class TxFormFactorEnum {
    public static final String phone = "phone";
    public static final String tablet = "tablet";
    public static final String desktop = "desktop";
    public static final String tv = "tv";
    public static final String watch = "watch";
    public static final String car = "car";
    public static final String embedded = "embedded";
    public static final String other = "other";
  }

  public static final class TxLogLevelEnum {
    public static final String none = "none";
    public static final String verbose = "verbose";
    public static final String debug = "debug";
    public static final String info = "info";
    public static final String warn = "warn";
    public static final String error = "error";
  }

  public static final class TxDevicePlatformEnum {
    public static final String ios = "ios";
    public static final String android = "android";
    public static final String browser = "browser";
  }

  public static final class TxDevicePushStateEnum {
    public static final String active = "active";
    public static final String failing = "failing";
    public static final String failed = "failed";
  }

  public static final class TxConnectionStateChange {
    public static final String current = "current";
    public static final String previous = "previous";
    public static final String event = "event";
    public static final String retryIn = "retryIn";
    public static final String reason = "reason";
  }

  public static final class TxChannelStateChange {
    public static final String current = "current";
    public static final String previous = "previous";
    public static final String event = "event";
    public static final String resumed = "resumed";
    public static final String reason = "reason";
  }

  public static final class TxMessage {
    public static final String id = "id";
    public static final String timestamp = "timestamp";
    public static final String clientId = "clientId";
    public static final String connectionId = "connectionId";
    public static final String encoding = "encoding";
    public static final String data = "data";
    public static final String name = "name";
    public static final String extras = "extras";
  }

  public static final class TxPresenceMessage {
    public static final String id = "id";
    public static final String action = "action";
    public static final String clientId = "clientId";
    public static final String connectionId = "connectionId";
    public static final String data = "data";
    public static final String encoding = "encoding";
    public static final String extras = "extras";
    public static final String timestamp = "timestamp";
  }

  public static final class TxPaginatedResult {
    public static final String items = "items";
    public static final String type = "type";
    public static final String hasNext = "hasNext";
  }

  public static final class TxRestHistoryParams {
    public static final String start = "start";
    public static final String end = "end";
    public static final String direction = "direction";
    public static final String limit = "limit";
  }

  public static final class TxRealtimeHistoryParams {
    public static final String start = "start";
    public static final String end = "end";
    public static final String direction = "direction";
    public static final String limit = "limit";
    public static final String untilAttach = "untilAttach";
  }

  public static final class TxRestPresenceParams {
    public static final String limit = "limit";
    public static final String clientId = "clientId";
    public static final String connectionId = "connectionId";
  }

  public static final class TxRealtimePresenceParams {
    public static final String waitForSync = "waitForSync";
    public static final String clientId = "clientId";
    public static final String connectionId = "connectionId";
  }

  public static final class TxDeviceDetails {
    public static final String id = "id";
    public static final String clientId = "clientId";
    public static final String platform = "platform";
    public static final String formFactor = "formFactor";
    public static final String metadata = "metadata";
    public static final String devicePushDetails = "devicePushDetails";
  }

  public static final class TxDevicePushDetails {
    public static final String recipient = "recipient";
    public static final String state = "state";
    public static final String errorReason = "errorReason";
  }

  public static final class TxLocalDevice {
    public static final String deviceSecret = "deviceSecret";
    public static final String deviceIdentityToken = "deviceIdentityToken";
  }

  public static final class TxPushChannelSubscription {
    public static final String channel = "channel";
    public static final String deviceId = "deviceId";
    public static final String clientId = "clientId";
  }

  public static final class TxPushRequestPermission {
    public static final String badge = "badge";
    public static final String sound = "sound";
    public static final String alert = "alert";
    public static final String carPlay = "carPlay";
    public static final String criticalAlert = "criticalAlert";
    public static final String providesAppNotificationSettings = "providesAppNotificationSettings";
    public static final String provisional = "provisional";
    public static final String announcement = "announcement";
  }

  public static final class TxUNNotificationSettings {
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

  public static final class TxUNNotificationSettingEnum {
    public static final String notSupported = "notSupported";
    public static final String disabled = "disabled";
    public static final String enabled = "enabled";
  }

  public static final class TxUNAlertStyleEnum {
    public static final String none = "none";
    public static final String banner = "banner";
    public static final String alert = "alert";
  }

  public static final class TxUNAuthorizationStatusEnum {
    public static final String notDetermined = "notDetermined";
    public static final String denied = "denied";
    public static final String authorized = "authorized";
    public static final String provisional = "provisional";
    public static final String ephemeral = "ephemeral";
  }

  public static final class TxUNShowPreviewsSettingEnum {
    public static final String always = "always";
    public static final String whenAuthenticated = "whenAuthenticated";
    public static final String never = "never";
  }

  public static final class TxRemoteMessage {
    public static final String data = "data";
    public static final String notification = "notification";
  }

  public static final class TxNotification {
    public static final String title = "title";
    public static final String body = "body";
  }

  public static final class TxCryptoGetParams {
    public static final String algorithm = "algorithm";
    public static final String key = "key";
  }

  public static final class TxCryptoGenerateRandomKey {
    public static final String keyLength = "keyLength";
  }

  public static final class TxStats {
    public static final String all = "all";
    public static final String apiRequests = "apiRequests";
    public static final String channels = "channels";
    public static final String connections = "connections";
    public static final String inbound = "inbound";
    public static final String intervalId = "intervalId";
    public static final String outbound = "outbound";
    public static final String persisted = "persisted";
    public static final String tokenRequests = "tokenRequests";
  }

  public static final class TxStatsMessageTypes {
    public static final String all = "all";
    public static final String messages = "messages";
    public static final String presence = "presence";
  }

  public static final class TxStatsMessageCount {
    public static final String count = "count";
    public static final String data = "data";
  }

  public static final class TxStatsRequestCount {
    public static final String failed = "failed";
    public static final String refused = "refused";
    public static final String succeeded = "succeeded";
  }

  public static final class TxStatsResourceCount {
    public static final String mean = "mean";
    public static final String min = "min";
    public static final String opened = "opened";
    public static final String peak = "peak";
    public static final String refused = "refused";
  }

  public static final class TxStatsConnectionTypes {
    public static final String all = "all";
    public static final String plain = "plain";
    public static final String tls = "tls";
  }

  public static final class TxStatsMessageTraffic {
    public static final String all = "all";
    public static final String realtime = "realtime";
    public static final String rest = "rest";
    public static final String webhook = "webhook";
  }
}
