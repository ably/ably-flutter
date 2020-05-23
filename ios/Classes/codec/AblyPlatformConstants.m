//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

#import <Foundation/Foundation.h>
#import "AblyPlatformConstants.h"


@implementation AblyPlatformMethod
+ (NSString*) getPlatformVersion { return @"getPlatformVersion"; }
+ (NSString*) getVersion { return @"getVersion"; }
+ (NSString*) registerAbly { return @"registerAbly"; }
+ (NSString*) createRestWithOptions { return @"createRestWithOptions"; }
+ (NSString*) publish { return @"publish"; }
+ (NSString*) createRealtimeWithOptions { return @"createRealtimeWithOptions"; }
+ (NSString*) connectRealtime { return @"connectRealtime"; }
+ (NSString*) closeRealtime { return @"closeRealtime"; }
+ (NSString*) onRealtimeConnectionStateChanged { return @"onRealtimeConnectionStateChanged"; }
+ (NSString*) onRealtimeChannelStateChanged { return @"onRealtimeChannelStateChanged"; }
@end

@implementation TxAblyMessage
+ (NSString*) registrationHandle { return @"registrationHandle"; }
+ (NSString*) type { return @"type"; }
+ (NSString*) message { return @"message"; }
@end

@implementation TxErrorInfo
+ (NSString*) code { return @"code"; }
+ (NSString*) message { return @"message"; }
+ (NSString*) statusCode { return @"statusCode"; }
+ (NSString*) href { return @"href"; }
+ (NSString*) requestId { return @"requestId"; }
+ (NSString*) cause { return @"cause"; }
@end

@implementation TxClientOptions
+ (NSString*) authUrl { return @"authUrl"; }
+ (NSString*) authMethod { return @"authMethod"; }
+ (NSString*) key { return @"key"; }
+ (NSString*) tokenDetails { return @"tokenDetails"; }
+ (NSString*) authHeaders { return @"authHeaders"; }
+ (NSString*) authParams { return @"authParams"; }
+ (NSString*) queryTime { return @"queryTime"; }
+ (NSString*) useTokenAuth { return @"useTokenAuth"; }
+ (NSString*) clientId { return @"clientId"; }
+ (NSString*) logLevel { return @"logLevel"; }
+ (NSString*) tls { return @"tls"; }
+ (NSString*) restHost { return @"restHost"; }
+ (NSString*) realtimeHost { return @"realtimeHost"; }
+ (NSString*) port { return @"port"; }
+ (NSString*) tlsPort { return @"tlsPort"; }
+ (NSString*) autoConnect { return @"autoConnect"; }
+ (NSString*) useBinaryProtocol { return @"useBinaryProtocol"; }
+ (NSString*) queueMessages { return @"queueMessages"; }
+ (NSString*) echoMessages { return @"echoMessages"; }
+ (NSString*) recover { return @"recover"; }
+ (NSString*) environment { return @"environment"; }
+ (NSString*) idempotentRestPublishing { return @"idempotentRestPublishing"; }
+ (NSString*) httpOpenTimeout { return @"httpOpenTimeout"; }
+ (NSString*) httpRequestTimeout { return @"httpRequestTimeout"; }
+ (NSString*) httpMaxRetryCount { return @"httpMaxRetryCount"; }
+ (NSString*) realtimeRequestTimeout { return @"realtimeRequestTimeout"; }
+ (NSString*) fallbackHosts { return @"fallbackHosts"; }
+ (NSString*) fallbackHostsUseDefault { return @"fallbackHostsUseDefault"; }
+ (NSString*) fallbackRetryTimeout { return @"fallbackRetryTimeout"; }
+ (NSString*) defaultTokenParams { return @"defaultTokenParams"; }
+ (NSString*) channelRetryTimeout { return @"channelRetryTimeout"; }
+ (NSString*) transportParams { return @"transportParams"; }
@end

@implementation TxTokenDetails
+ (NSString*) token { return @"token"; }
+ (NSString*) expires { return @"expires"; }
+ (NSString*) issued { return @"issued"; }
+ (NSString*) capability { return @"capability"; }
+ (NSString*) clientId { return @"clientId"; }
@end

@implementation TxTokenParams
+ (NSString*) capability { return @"capability"; }
+ (NSString*) clientId { return @"clientId"; }
+ (NSString*) nonce { return @"nonce"; }
+ (NSString*) timestamp { return @"timestamp"; }
+ (NSString*) ttl { return @"ttl"; }
@end

@implementation TxConnectionStateChange
+ (NSString*) current { return @"current"; }
+ (NSString*) previous { return @"previous"; }
+ (NSString*) event { return @"event"; }
+ (NSString*) retryIn { return @"retryIn"; }
+ (NSString*) reason { return @"reason"; }
@end

@implementation TxChannelStateChange
+ (NSString*) current { return @"current"; }
+ (NSString*) previous { return @"previous"; }
+ (NSString*) event { return @"event"; }
+ (NSString*) resumed { return @"resumed"; }
+ (NSString*) reason { return @"reason"; }
@end
