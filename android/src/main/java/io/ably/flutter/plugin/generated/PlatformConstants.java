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
        public static final byte message = (byte) 131;
        public static final byte tokenParams = (byte) 132;
        public static final byte tokenDetails = (byte) 133;
        public static final byte tokenRequest = (byte) 134;
        public static final byte paginatedResult = (byte) 135;
        public static final byte restHistoryParams = (byte) 136;
        public static final byte errorInfo = (byte) 144;
        public static final byte connectionStateChange = (byte) 201;
        public static final byte channelStateChange = (byte) 202;
    }

    static final public class PlatformMethod {
        public static final String getPlatformVersion = "getPlatformVersion";
        public static final String getVersion = "getVersion";
        public static final String registerAbly = "registerAbly";
        public static final String authCallback = "authCallback";
        public static final String realtimeAuthCallback = "realtimeAuthCallback";
        public static final String createRestWithOptions = "createRestWithOptions";
        public static final String publish = "publish";
        public static final String createRealtimeWithOptions = "createRealtimeWithOptions";
        public static final String connectRealtime = "connectRealtime";
        public static final String closeRealtime = "closeRealtime";
        public static final String attachRealtimeChannel = "attachRealtimeChannel";
        public static final String detachRealtimeChannel = "detachRealtimeChannel";
        public static final String setRealtimeChannelOptions = "setRealtimeChannelOptions";
        public static final String publishRealtimeChannelMessage = "publishRealtimeChannelMessage";
        public static final String onRealtimeConnectionStateChanged = "onRealtimeConnectionStateChanged";
        public static final String onRealtimeChannelStateChanged = "onRealtimeChannelStateChanged";
        public static final String onRealtimeChannelMessage = "onRealtimeChannelMessage";
        public static final String restHistory = "restHistory";
        public static final String realtimeHistory = "realtimeHistory";
        public static final String nextPage = "nextPage";
        public static final String firstPage = "firstPage";
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

    static final public class TxTokenDetails {
        public static final String token = "token";
        public static final String expires = "expires";
        public static final String issued = "issued";
        public static final String capability = "capability";
        public static final String clientId = "clientId";
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
        public static final String update = "update";
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

    static final public class TxPaginatedResult {
        public static final String items = "items";
        public static final String type = "type";
        public static final String hasNext = "hasNext";
    }

    static final public class TxRestHistoryArguments {
        public static final String channelName = "channelName";
        public static final String params = "params";
    }

    static final public class TxRestHistoryParams {
        public static final String start = "start";
        public static final String end = "end";
        public static final String direction = "direction";
        public static final String limit = "limit";
    }

}
