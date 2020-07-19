//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

class CodecTypes{
	static const int ablyMessage = 128;
	static const int ablyEventMessage = 129;
	static const int clientOptions = 130;
	static const int errorInfo = 144;
	static const int connectionStateChange = 201;
	static const int channelStateChange = 202;
}

class PlatformMethod {
	static const String getPlatformVersion = 'getPlatformVersion';
	static const String getVersion = 'getVersion';
	static const String registerAbly = 'registerAbly';
	static const String createRestWithOptions = 'createRestWithOptions';
	static const String publish = 'publish';
	static const String createRealtimeWithOptions = 'createRealtimeWithOptions';
	static const String connectRealtime = 'connectRealtime';
	static const String closeRealtime = 'closeRealtime';
	static const String onRealtimeConnectionStateChanged = 'onRealtimeConnectionStateChanged';
	static const String onRealtimeChannelStateChanged = 'onRealtimeChannelStateChanged';
}

class TxAblyMessage{
	static const String registrationHandle = "registrationHandle";
	static const String type = "type";
	static const String message = "message";
}

class TxAblyEventMessage{
	static const String eventName = "eventName";
	static const String type = "type";
	static const String message = "message";
}

class TxErrorInfo{
	static const String code = "code";
	static const String message = "message";
	static const String statusCode = "statusCode";
	static const String href = "href";
	static const String requestId = "requestId";
	static const String cause = "cause";
}

class TxClientOptions{
	static const String authUrl = "authUrl";
	static const String authMethod = "authMethod";
	static const String key = "key";
	static const String tokenDetails = "tokenDetails";
	static const String authHeaders = "authHeaders";
	static const String authParams = "authParams";
	static const String queryTime = "queryTime";
	static const String useTokenAuth = "useTokenAuth";
	static const String clientId = "clientId";
	static const String logLevel = "logLevel";
	static const String tls = "tls";
	static const String restHost = "restHost";
	static const String realtimeHost = "realtimeHost";
	static const String port = "port";
	static const String tlsPort = "tlsPort";
	static const String autoConnect = "autoConnect";
	static const String useBinaryProtocol = "useBinaryProtocol";
	static const String queueMessages = "queueMessages";
	static const String echoMessages = "echoMessages";
	static const String recover = "recover";
	static const String environment = "environment";
	static const String idempotentRestPublishing = "idempotentRestPublishing";
	static const String httpOpenTimeout = "httpOpenTimeout";
	static const String httpRequestTimeout = "httpRequestTimeout";
	static const String httpMaxRetryCount = "httpMaxRetryCount";
	static const String realtimeRequestTimeout = "realtimeRequestTimeout";
	static const String fallbackHosts = "fallbackHosts";
	static const String fallbackHostsUseDefault = "fallbackHostsUseDefault";
	static const String fallbackRetryTimeout = "fallbackRetryTimeout";
	static const String defaultTokenParams = "defaultTokenParams";
	static const String channelRetryTimeout = "channelRetryTimeout";
	static const String transportParams = "transportParams";
}

class TxTokenDetails{
	static const String token = "token";
	static const String expires = "expires";
	static const String issued = "issued";
	static const String capability = "capability";
	static const String clientId = "clientId";
}

class TxTokenParams{
	static const String capability = "capability";
	static const String clientId = "clientId";
	static const String nonce = "nonce";
	static const String timestamp = "timestamp";
	static const String ttl = "ttl";
}

class TxConnectionStateChange{
	static const String current = "current";
	static const String previous = "previous";
	static const String event = "event";
	static const String retryIn = "retryIn";
	static const String reason = "reason";
}

class TxChannelStateChange{
	static const String current = "current";
	static const String previous = "previous";
	static const String event = "event";
	static const String resumed = "resumed";
	static const String reason = "reason";
}

