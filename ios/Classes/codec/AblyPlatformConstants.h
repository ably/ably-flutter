//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt8, _Value) {
  ablyMessageCodecType = 128,
  clientOptionsCodecType = 129,
  errorInfoCodecType = 144,
  connectionStateChangeCodecType = 201,
  channelStateChangeCodecType = 202,
};


@interface AblyPlatformMethod : NSObject
@property (class, nonatomic, assign, readonly) NSString *getPlatformVersion;
@property (class, nonatomic, assign, readonly) NSString *getVersion;
@property (class, nonatomic, assign, readonly) NSString *registerAbly;
@property (class, nonatomic, assign, readonly) NSString *createRestWithOptions;
@property (class, nonatomic, assign, readonly) NSString *publish;
@property (class, nonatomic, assign, readonly) NSString *createRealtimeWithOptions;
@property (class, nonatomic, assign, readonly) NSString *connectRealtime;
@property (class, nonatomic, assign, readonly) NSString *closeRealtime;
@property (class, nonatomic, assign, readonly) NSString *onRealtimeConnectionStateChanged;
@property (class, nonatomic, assign, readonly) NSString *onRealtimeChannelStateChanged;
@end

@interface TxAblyMessage : NSObject
@property (class, nonatomic, assign, readonly) NSString *registrationHandle;
@property (class, nonatomic, assign, readonly) NSString *type;
@property (class, nonatomic, assign, readonly) NSString *message;
@end

@interface TxErrorInfo : NSObject
@property (class, nonatomic, assign, readonly) NSString *code;
@property (class, nonatomic, assign, readonly) NSString *message;
@property (class, nonatomic, assign, readonly) NSString *statusCode;
@property (class, nonatomic, assign, readonly) NSString *href;
@property (class, nonatomic, assign, readonly) NSString *requestId;
@property (class, nonatomic, assign, readonly) NSString *cause;
@end

@interface TxClientOptions : NSObject
@property (class, nonatomic, assign, readonly) NSString *authUrl;
@property (class, nonatomic, assign, readonly) NSString *authMethod;
@property (class, nonatomic, assign, readonly) NSString *key;
@property (class, nonatomic, assign, readonly) NSString *tokenDetails;
@property (class, nonatomic, assign, readonly) NSString *authHeaders;
@property (class, nonatomic, assign, readonly) NSString *authParams;
@property (class, nonatomic, assign, readonly) NSString *queryTime;
@property (class, nonatomic, assign, readonly) NSString *useTokenAuth;
@property (class, nonatomic, assign, readonly) NSString *clientId;
@property (class, nonatomic, assign, readonly) NSString *logLevel;
@property (class, nonatomic, assign, readonly) NSString *tls;
@property (class, nonatomic, assign, readonly) NSString *restHost;
@property (class, nonatomic, assign, readonly) NSString *realtimeHost;
@property (class, nonatomic, assign, readonly) NSString *port;
@property (class, nonatomic, assign, readonly) NSString *tlsPort;
@property (class, nonatomic, assign, readonly) NSString *autoConnect;
@property (class, nonatomic, assign, readonly) NSString *useBinaryProtocol;
@property (class, nonatomic, assign, readonly) NSString *queueMessages;
@property (class, nonatomic, assign, readonly) NSString *echoMessages;
@property (class, nonatomic, assign, readonly) NSString *recover;
@property (class, nonatomic, assign, readonly) NSString *environment;
@property (class, nonatomic, assign, readonly) NSString *idempotentRestPublishing;
@property (class, nonatomic, assign, readonly) NSString *httpOpenTimeout;
@property (class, nonatomic, assign, readonly) NSString *httpRequestTimeout;
@property (class, nonatomic, assign, readonly) NSString *httpMaxRetryCount;
@property (class, nonatomic, assign, readonly) NSString *realtimeRequestTimeout;
@property (class, nonatomic, assign, readonly) NSString *fallbackHosts;
@property (class, nonatomic, assign, readonly) NSString *fallbackHostsUseDefault;
@property (class, nonatomic, assign, readonly) NSString *fallbackRetryTimeout;
@property (class, nonatomic, assign, readonly) NSString *defaultTokenParams;
@property (class, nonatomic, assign, readonly) NSString *channelRetryTimeout;
@property (class, nonatomic, assign, readonly) NSString *transportParams;
@end

@interface TxTokenDetails : NSObject
@property (class, nonatomic, assign, readonly) NSString *token;
@property (class, nonatomic, assign, readonly) NSString *expires;
@property (class, nonatomic, assign, readonly) NSString *issued;
@property (class, nonatomic, assign, readonly) NSString *capability;
@property (class, nonatomic, assign, readonly) NSString *clientId;
@end

@interface TxTokenParams : NSObject
@property (class, nonatomic, assign, readonly) NSString *capability;
@property (class, nonatomic, assign, readonly) NSString *clientId;
@property (class, nonatomic, assign, readonly) NSString *nonce;
@property (class, nonatomic, assign, readonly) NSString *timestamp;
@property (class, nonatomic, assign, readonly) NSString *ttl;
@end

@interface TxConnectionStateChange : NSObject
@property (class, nonatomic, assign, readonly) NSString *current;
@property (class, nonatomic, assign, readonly) NSString *previous;
@property (class, nonatomic, assign, readonly) NSString *event;
@property (class, nonatomic, assign, readonly) NSString *retryIn;
@property (class, nonatomic, assign, readonly) NSString *reason;
@end

@interface TxChannelStateChange : NSObject
@property (class, nonatomic, assign, readonly) NSString *current;
@property (class, nonatomic, assign, readonly) NSString *previous;
@property (class, nonatomic, assign, readonly) NSString *event;
@property (class, nonatomic, assign, readonly) NSString *resumed;
@property (class, nonatomic, assign, readonly) NSString *reason;
@end
