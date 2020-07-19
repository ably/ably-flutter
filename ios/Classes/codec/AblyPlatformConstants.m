//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

#import "AblyPlatformConstants.h"


@implementation AblyPlatformMethod
NSString *const AblyPlatformMethod_getPlatformVersion= @"getPlatformVersion";
NSString *const AblyPlatformMethod_getVersion= @"getVersion";
NSString *const AblyPlatformMethod_registerAbly= @"registerAbly";
NSString *const AblyPlatformMethod_createRestWithOptions= @"createRestWithOptions";
NSString *const AblyPlatformMethod_publish= @"publish";
NSString *const AblyPlatformMethod_createRealtimeWithOptions= @"createRealtimeWithOptions";
NSString *const AblyPlatformMethod_connectRealtime= @"connectRealtime";
NSString *const AblyPlatformMethod_closeRealtime= @"closeRealtime";
NSString *const AblyPlatformMethod_onRealtimeConnectionStateChanged= @"onRealtimeConnectionStateChanged";
NSString *const AblyPlatformMethod_onRealtimeChannelStateChanged= @"onRealtimeChannelStateChanged";
@end

@implementation TxAblyMessage
NSString *const TxAblyMessage_registrationHandle = @"registrationHandle";
NSString *const TxAblyMessage_type = @"type";
NSString *const TxAblyMessage_message = @"message";
@end

@implementation TxAblyEventMessage
NSString *const TxAblyEventMessage_eventName = @"eventName";
NSString *const TxAblyEventMessage_type = @"type";
NSString *const TxAblyEventMessage_message = @"message";
@end

@implementation TxErrorInfo
NSString *const TxErrorInfo_code = @"code";
NSString *const TxErrorInfo_message = @"message";
NSString *const TxErrorInfo_statusCode = @"statusCode";
NSString *const TxErrorInfo_href = @"href";
NSString *const TxErrorInfo_requestId = @"requestId";
NSString *const TxErrorInfo_cause = @"cause";
@end

@implementation TxClientOptions
NSString *const TxClientOptions_authUrl = @"authUrl";
NSString *const TxClientOptions_authMethod = @"authMethod";
NSString *const TxClientOptions_key = @"key";
NSString *const TxClientOptions_tokenDetails = @"tokenDetails";
NSString *const TxClientOptions_authHeaders = @"authHeaders";
NSString *const TxClientOptions_authParams = @"authParams";
NSString *const TxClientOptions_queryTime = @"queryTime";
NSString *const TxClientOptions_useTokenAuth = @"useTokenAuth";
NSString *const TxClientOptions_clientId = @"clientId";
NSString *const TxClientOptions_logLevel = @"logLevel";
NSString *const TxClientOptions_tls = @"tls";
NSString *const TxClientOptions_restHost = @"restHost";
NSString *const TxClientOptions_realtimeHost = @"realtimeHost";
NSString *const TxClientOptions_port = @"port";
NSString *const TxClientOptions_tlsPort = @"tlsPort";
NSString *const TxClientOptions_autoConnect = @"autoConnect";
NSString *const TxClientOptions_useBinaryProtocol = @"useBinaryProtocol";
NSString *const TxClientOptions_queueMessages = @"queueMessages";
NSString *const TxClientOptions_echoMessages = @"echoMessages";
NSString *const TxClientOptions_recover = @"recover";
NSString *const TxClientOptions_environment = @"environment";
NSString *const TxClientOptions_idempotentRestPublishing = @"idempotentRestPublishing";
NSString *const TxClientOptions_httpOpenTimeout = @"httpOpenTimeout";
NSString *const TxClientOptions_httpRequestTimeout = @"httpRequestTimeout";
NSString *const TxClientOptions_httpMaxRetryCount = @"httpMaxRetryCount";
NSString *const TxClientOptions_realtimeRequestTimeout = @"realtimeRequestTimeout";
NSString *const TxClientOptions_fallbackHosts = @"fallbackHosts";
NSString *const TxClientOptions_fallbackHostsUseDefault = @"fallbackHostsUseDefault";
NSString *const TxClientOptions_fallbackRetryTimeout = @"fallbackRetryTimeout";
NSString *const TxClientOptions_defaultTokenParams = @"defaultTokenParams";
NSString *const TxClientOptions_channelRetryTimeout = @"channelRetryTimeout";
NSString *const TxClientOptions_transportParams = @"transportParams";
@end

@implementation TxTokenDetails
NSString *const TxTokenDetails_token = @"token";
NSString *const TxTokenDetails_expires = @"expires";
NSString *const TxTokenDetails_issued = @"issued";
NSString *const TxTokenDetails_capability = @"capability";
NSString *const TxTokenDetails_clientId = @"clientId";
@end

@implementation TxTokenParams
NSString *const TxTokenParams_capability = @"capability";
NSString *const TxTokenParams_clientId = @"clientId";
NSString *const TxTokenParams_nonce = @"nonce";
NSString *const TxTokenParams_timestamp = @"timestamp";
NSString *const TxTokenParams_ttl = @"ttl";
@end

@implementation TxConnectionStateChange
NSString *const TxConnectionStateChange_current = @"current";
NSString *const TxConnectionStateChange_previous = @"previous";
NSString *const TxConnectionStateChange_event = @"event";
NSString *const TxConnectionStateChange_retryIn = @"retryIn";
NSString *const TxConnectionStateChange_reason = @"reason";
@end

@implementation TxChannelStateChange
NSString *const TxChannelStateChange_current = @"current";
NSString *const TxChannelStateChange_previous = @"previous";
NSString *const TxChannelStateChange_event = @"event";
NSString *const TxChannelStateChange_resumed = @"resumed";
NSString *const TxChannelStateChange_reason = @"reason";
@end
