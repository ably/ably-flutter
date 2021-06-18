//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

#import "AblyPlatformConstants.h"


// flutter platform channel method names
NSString *const AblyPlatformMethod_getPlatformVersion= @"getPlatformVersion";
NSString *const AblyPlatformMethod_getVersion= @"getVersion";
NSString *const AblyPlatformMethod_registerAbly= @"registerAbly";
NSString *const AblyPlatformMethod_authCallback= @"authCallback";
NSString *const AblyPlatformMethod_realtimeAuthCallback= @"realtimeAuthCallback";
NSString *const AblyPlatformMethod_createRestWithOptions= @"createRestWithOptions";
NSString *const AblyPlatformMethod_setRestChannelOptions= @"setRestChannelOptions";
NSString *const AblyPlatformMethod_publish= @"publish";
NSString *const AblyPlatformMethod_restHistory= @"restHistory";
NSString *const AblyPlatformMethod_restPresenceGet= @"restPresenceGet";
NSString *const AblyPlatformMethod_restPresenceHistory= @"restPresenceHistory";
NSString *const AblyPlatformMethod_releaseRestChannel= @"releaseRestChannel";
NSString *const AblyPlatformMethod_createRealtimeWithOptions= @"createRealtimeWithOptions";
NSString *const AblyPlatformMethod_connectRealtime= @"connectRealtime";
NSString *const AblyPlatformMethod_closeRealtime= @"closeRealtime";
NSString *const AblyPlatformMethod_attachRealtimeChannel= @"attachRealtimeChannel";
NSString *const AblyPlatformMethod_detachRealtimeChannel= @"detachRealtimeChannel";
NSString *const AblyPlatformMethod_setRealtimeChannelOptions= @"setRealtimeChannelOptions";
NSString *const AblyPlatformMethod_realtimePresenceGet= @"realtimePresenceGet";
NSString *const AblyPlatformMethod_realtimePresenceHistory= @"realtimePresenceHistory";
NSString *const AblyPlatformMethod_realtimePresenceEnter= @"realtimePresenceEnter";
NSString *const AblyPlatformMethod_realtimePresenceUpdate= @"realtimePresenceUpdate";
NSString *const AblyPlatformMethod_realtimePresenceLeave= @"realtimePresenceLeave";
NSString *const AblyPlatformMethod_onRealtimePresenceMessage= @"onRealtimePresenceMessage";
NSString *const AblyPlatformMethod_publishRealtimeChannelMessage= @"publishRealtimeChannelMessage";
NSString *const AblyPlatformMethod_releaseRealtimeChannel= @"releaseRealtimeChannel";
NSString *const AblyPlatformMethod_realtimeHistory= @"realtimeHistory";
NSString *const AblyPlatformMethod_onRealtimeConnectionStateChanged= @"onRealtimeConnectionStateChanged";
NSString *const AblyPlatformMethod_onRealtimeChannelStateChanged= @"onRealtimeChannelStateChanged";
NSString *const AblyPlatformMethod_onRealtimeChannelMessage= @"onRealtimeChannelMessage";
NSString *const AblyPlatformMethod_nextPage= @"nextPage";
NSString *const AblyPlatformMethod_firstPage= @"firstPage";

// key constants for TransportKeys
NSString *const TxTransportKeys_channelName = @"channelName";
NSString *const TxTransportKeys_params = @"params";
NSString *const TxTransportKeys_data = @"data";
NSString *const TxTransportKeys_clientId = @"clientId";
NSString *const TxTransportKeys_options = @"options";
NSString *const TxTransportKeys_messages = @"messages";

// key constants for AblyMessage
NSString *const TxAblyMessage_registrationHandle = @"registrationHandle";
NSString *const TxAblyMessage_type = @"type";
NSString *const TxAblyMessage_message = @"message";

// key constants for AblyEventMessage
NSString *const TxAblyEventMessage_eventName = @"eventName";
NSString *const TxAblyEventMessage_type = @"type";
NSString *const TxAblyEventMessage_message = @"message";

// key constants for ErrorInfo
NSString *const TxErrorInfo_code = @"code";
NSString *const TxErrorInfo_message = @"message";
NSString *const TxErrorInfo_statusCode = @"statusCode";
NSString *const TxErrorInfo_href = @"href";
NSString *const TxErrorInfo_requestId = @"requestId";
NSString *const TxErrorInfo_cause = @"cause";

// key constants for MessageData
NSString *const TxMessageData_data = @"data";
NSString *const TxMessageData_type = @"type";

// key constants for DeltaExtras
NSString *const TxDeltaExtras_format = @"format";
NSString *const TxDeltaExtras_from = @"from";

// key constants for MessageExtras
NSString *const TxMessageExtras_extras = @"extras";
NSString *const TxMessageExtras_delta = @"delta";

// key constants for ClientOptions
NSString *const TxClientOptions_authUrl = @"authUrl";
NSString *const TxClientOptions_authMethod = @"authMethod";
NSString *const TxClientOptions_key = @"key";
NSString *const TxClientOptions_tokenDetails = @"tokenDetails";
NSString *const TxClientOptions_authHeaders = @"authHeaders";
NSString *const TxClientOptions_authParams = @"authParams";
NSString *const TxClientOptions_queryTime = @"queryTime";
NSString *const TxClientOptions_useTokenAuth = @"useTokenAuth";
NSString *const TxClientOptions_hasAuthCallback = @"hasAuthCallback";
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

// key constants for RestChannelOptions
NSString *const TxRestChannelOptions_cipher = @"cipher";

// key constants for RealtimeChannelOptions
NSString *const TxRealtimeChannelOptions_cipher = @"cipher";
NSString *const TxRealtimeChannelOptions_params = @"params";
NSString *const TxRealtimeChannelOptions_modes = @"modes";

// key constants for TokenDetails
NSString *const TxTokenDetails_token = @"token";
NSString *const TxTokenDetails_expires = @"expires";
NSString *const TxTokenDetails_issued = @"issued";
NSString *const TxTokenDetails_capability = @"capability";
NSString *const TxTokenDetails_clientId = @"clientId";

// key constants for TokenParams
NSString *const TxTokenParams_capability = @"capability";
NSString *const TxTokenParams_clientId = @"clientId";
NSString *const TxTokenParams_nonce = @"nonce";
NSString *const TxTokenParams_timestamp = @"timestamp";
NSString *const TxTokenParams_ttl = @"ttl";

// key constants for TokenRequest
NSString *const TxTokenRequest_capability = @"capability";
NSString *const TxTokenRequest_clientId = @"clientId";
NSString *const TxTokenRequest_keyName = @"keyName";
NSString *const TxTokenRequest_mac = @"mac";
NSString *const TxTokenRequest_nonce = @"nonce";
NSString *const TxTokenRequest_timestamp = @"timestamp";
NSString *const TxTokenRequest_ttl = @"ttl";

// key constants for EnumConstants
NSString *const TxEnumConstants_initialized = @"initialized";
NSString *const TxEnumConstants_connecting = @"connecting";
NSString *const TxEnumConstants_connected = @"connected";
NSString *const TxEnumConstants_disconnected = @"disconnected";
NSString *const TxEnumConstants_attaching = @"attaching";
NSString *const TxEnumConstants_attached = @"attached";
NSString *const TxEnumConstants_detaching = @"detaching";
NSString *const TxEnumConstants_detached = @"detached";
NSString *const TxEnumConstants_suspended = @"suspended";
NSString *const TxEnumConstants_closing = @"closing";
NSString *const TxEnumConstants_closed = @"closed";
NSString *const TxEnumConstants_failed = @"failed";
NSString *const TxEnumConstants_absent = @"absent";
NSString *const TxEnumConstants_leave = @"leave";
NSString *const TxEnumConstants_enter = @"enter";
NSString *const TxEnumConstants_present = @"present";
NSString *const TxEnumConstants_update = @"update";
NSString *const TxEnumConstants_presence = @"presence";
NSString *const TxEnumConstants_publish = @"publish";
NSString *const TxEnumConstants_subscribe = @"subscribe";
NSString *const TxEnumConstants_presenceSubscribe = @"presenceSubscribe";

// key constants for ConnectionStateChange
NSString *const TxConnectionStateChange_current = @"current";
NSString *const TxConnectionStateChange_previous = @"previous";
NSString *const TxConnectionStateChange_event = @"event";
NSString *const TxConnectionStateChange_retryIn = @"retryIn";
NSString *const TxConnectionStateChange_reason = @"reason";

// key constants for ChannelStateChange
NSString *const TxChannelStateChange_current = @"current";
NSString *const TxChannelStateChange_previous = @"previous";
NSString *const TxChannelStateChange_event = @"event";
NSString *const TxChannelStateChange_resumed = @"resumed";
NSString *const TxChannelStateChange_reason = @"reason";

// key constants for Message
NSString *const TxMessage_id = @"id";
NSString *const TxMessage_timestamp = @"timestamp";
NSString *const TxMessage_clientId = @"clientId";
NSString *const TxMessage_connectionId = @"connectionId";
NSString *const TxMessage_encoding = @"encoding";
NSString *const TxMessage_data = @"data";
NSString *const TxMessage_name = @"name";
NSString *const TxMessage_extras = @"extras";

// key constants for PresenceMessage
NSString *const TxPresenceMessage_id = @"id";
NSString *const TxPresenceMessage_action = @"action";
NSString *const TxPresenceMessage_clientId = @"clientId";
NSString *const TxPresenceMessage_connectionId = @"connectionId";
NSString *const TxPresenceMessage_data = @"data";
NSString *const TxPresenceMessage_encoding = @"encoding";
NSString *const TxPresenceMessage_extras = @"extras";
NSString *const TxPresenceMessage_timestamp = @"timestamp";

// key constants for PaginatedResult
NSString *const TxPaginatedResult_items = @"items";
NSString *const TxPaginatedResult_type = @"type";
NSString *const TxPaginatedResult_hasNext = @"hasNext";

// key constants for RestHistoryParams
NSString *const TxRestHistoryParams_start = @"start";
NSString *const TxRestHistoryParams_end = @"end";
NSString *const TxRestHistoryParams_direction = @"direction";
NSString *const TxRestHistoryParams_limit = @"limit";

// key constants for RealtimeHistoryParams
NSString *const TxRealtimeHistoryParams_start = @"start";
NSString *const TxRealtimeHistoryParams_end = @"end";
NSString *const TxRealtimeHistoryParams_direction = @"direction";
NSString *const TxRealtimeHistoryParams_limit = @"limit";
NSString *const TxRealtimeHistoryParams_untilAttach = @"untilAttach";

// key constants for RestPresenceParams
NSString *const TxRestPresenceParams_limit = @"limit";
NSString *const TxRestPresenceParams_clientId = @"clientId";
NSString *const TxRestPresenceParams_connectionId = @"connectionId";

// key constants for RealtimePresenceParams
NSString *const TxRealtimePresenceParams_waitForSync = @"waitForSync";
NSString *const TxRealtimePresenceParams_clientId = @"clientId";
NSString *const TxRealtimePresenceParams_connectionId = @"connectionId";
