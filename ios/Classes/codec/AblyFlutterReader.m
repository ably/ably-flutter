#import "AblyFlutterReader.h"
#import "Ably.h"
#import "AblyFlutterMessage.h"
#import "AblyPlatformConstants.h"
#import "ARTTokenDetails.h"
#import "ARTTokenParams.h"


static ARTLogLevel _logLevel(NSNumber *const number) {
    switch (number.unsignedIntegerValue) {
        case 99: return ARTLogLevelNone;
        case 2: return ARTLogLevelVerbose;
        case 3: return ARTLogLevelDebug;
        case 4: return ARTLogLevelInfo;
        case 5: return ARTLogLevelWarn;
        case 6: return ARTLogLevelError;
    }
    return ARTLogLevelWarn;
}

NS_ASSUME_NONNULL_BEGIN

typedef id (^AblyCodecDecoder)(NSDictionary * dictionary);

NS_ASSUME_NONNULL_END

@implementation AblyFlutterReader


+ (AblyCodecDecoder) getDecoder:(const NSString*)type {
    NSDictionary<NSString *, AblyCodecDecoder>* _handlers = @{
        [NSString stringWithFormat:@"%d", ablyMessageCodecType]: readAblyFlutterMessage,
        [NSString stringWithFormat:@"%d", clientOptionsCodecType]: readClientOptions,
    };
    return [_handlers objectForKey:[NSString stringWithFormat:@"%@", type]];
}

-(id)readValueOfType:(const UInt8)type {
    AblyCodecDecoder decoder = [AblyFlutterReader getDecoder: [NSString stringWithFormat:@"%d", type]];
    if(decoder){
        return decoder([self readValue]);
    }else{
        return [super readValueOfType:type];
    }
}

static AblyCodecDecoder readAblyFlutterMessage = ^AblyFlutterMessage*(NSDictionary *const jsonDict) {
    AblyCodecDecoder decoder = [AblyFlutterReader getDecoder: [NSString stringWithFormat:@"%@", [jsonDict objectForKey:TxAblyMessage.type]]];
    id message = [jsonDict objectForKey:TxAblyMessage.message];
    if(decoder){
        message = decoder(message);
    }
    return [[AblyFlutterMessage alloc] initWithHandle:[jsonDict objectForKey:TxAblyMessage.registrationHandle] message:message];
};

/**
 A macro to reduce boilerplate code for each value read where the pattern is to
 use an explicitly received null from Dart (manifesting this side as a nil id)
 to indicate that this property should not be set.
 
 The idea behind this pattern is that the default values for properties remain
 defined by the platform specific client library SDK, with values received from
 Dart only calling Objective-C property setters when they need to be explicitly
 set.
 
 @note This pattern does not work in the scenario where a property has a non-nil
 id value by default, because our Dart code would be sending null to request
 that the property is cleared. If or when we come across this situation then
 a different pattern will be needed for that property - perhaps a placeholder
 object (other than null) that indicates the Objective-C property value is to be
 set to an id value of nil.
 */
#define ON_VALUE(BLOCK, JSON_DICT, JSON_KEY) { \
    const id value = [JSON_DICT objectForKey: JSON_KEY]; \
    if (value) { \
        BLOCK(value); \
    } \
}

#define READ_VALUE(OBJECT, PROPERTY, JSON_DICT, JSON_KEY) { \
    ON_VALUE(^(const id value) { OBJECT.PROPERTY = value; }, JSON_DICT, JSON_KEY); \
}

/**
 Where an NSNumber has been decoded and the property to be set is BOOL.
 */
#define READ_BOOL(OBJECT, PROPERTY, JSON_DICT, JSON_KEY) { \
    ON_VALUE(^(const id number) { OBJECT.PROPERTY = [number boolValue]; }, JSON_DICT, JSON_KEY); \
}

static AblyCodecDecoder readClientOptions = ^AblyFlutterMessage*(NSDictionary *const jsonDict) {
    ARTClientOptions *const o = [ARTClientOptions new];

    // AuthOptions (super class of ClientOptions)
    READ_VALUE(o, authUrl, jsonDict, TxClientOptions.authUrl);
    READ_VALUE(o, authMethod, jsonDict, TxClientOptions.authMethod);
    READ_VALUE(o, key, jsonDict, TxClientOptions.key);
    ON_VALUE(^(const id value) { o.tokenDetails = [AblyFlutterReader readTokenDetails: value]; }, jsonDict, TxClientOptions.tokenDetails);
    READ_VALUE(o, authHeaders, jsonDict, TxClientOptions.authHeaders);
    READ_VALUE(o, authParams, jsonDict, TxClientOptions.authParams);
    READ_VALUE(o, queryTime, jsonDict, TxClientOptions.queryTime);

    // ClientOptions
    READ_VALUE(o, clientId, jsonDict, TxClientOptions.clientId);
    ON_VALUE(^(const id value) { o.logLevel = _logLevel(value); }, jsonDict, TxClientOptions.logLevel);
    //TODO log handler
    READ_VALUE(o, tls, jsonDict, TxClientOptions.tls);
    READ_VALUE(o, restHost, jsonDict, TxClientOptions.restHost);
    READ_VALUE(o, realtimeHost, jsonDict, TxClientOptions.realtimeHost);
    READ_BOOL(o, autoConnect, jsonDict, TxClientOptions.autoConnect);
    READ_VALUE(o, useBinaryProtocol, jsonDict, TxClientOptions.useBinaryProtocol);
    READ_VALUE(o, queueMessages, jsonDict, TxClientOptions.queueMessages);
    READ_VALUE(o, echoMessages, jsonDict, TxClientOptions.echoMessages);
    READ_VALUE(o, recover, jsonDict, TxClientOptions.recover);
    READ_VALUE(o, environment, jsonDict, TxClientOptions.environment);
    READ_VALUE(o, idempotentRestPublishing, jsonDict, TxClientOptions.idempotentRestPublishing);
    READ_VALUE(o, fallbackHosts, jsonDict, TxClientOptions.fallbackHosts);
    READ_VALUE(o, fallbackHostsUseDefault, jsonDict, TxClientOptions.fallbackHostsUseDefault);
    ON_VALUE(^(const id value) { o.defaultTokenParams = [AblyFlutterReader readTokenParams: value]; }, jsonDict, TxClientOptions.defaultTokenParams);
    READ_VALUE(o, defaultTokenParams, jsonDict, TxClientOptions.defaultTokenParams);
    //Following properties not supported by Objective C library
    // READ_VALUE(o, useAuthToken); // property not found
    // READ_VALUE(o, port); // NSInteger
    // READ_VALUE(o, tlsPort); // NSInteger
    // READ_VALUE(o, httpOpenTimeout); // NSTimeInterval
    // READ_VALUE(o, httpRequestTimeout); // NSTimeInterval
    // READ_VALUE(o, httpMaxRetryCount); // NSUInteger
    // READ_VALUE(o, realtimeRequestTimeout); // NSTimeInterval
    // READ_VALUE(o, fallbackRetryTimeout); // property not found
    // READ_VALUE(o, channelRetryTimeout); // NSTimeInterval
    // READ_VALUE(o, transportParams); // property not found
    // READ_VALUE(o, asyncHttpThreadpoolSize); // property not found
    // READ_VALUE(o, pushFullWait);
    
    return o;
};

+(ARTTokenDetails *)readTokenDetails: (NSDictionary *) jsonDict {
    __block NSString *token = nil;
    __block NSDate *expires = nil;
    __block NSDate *issued = nil;
    __block NSString *capability = nil;
    __block NSString *clientId = nil;
    
    ON_VALUE(^(const id value) { token = value; }, jsonDict, TxTokenDetails.token);
    ON_VALUE(^(const id value) { expires = value; }, jsonDict, TxTokenDetails.expires);
    ON_VALUE(^(const id value) { issued = value; }, jsonDict, TxTokenDetails.issued);
    ON_VALUE(^(const id value) { capability = value; }, jsonDict, TxTokenDetails.capability);
    ON_VALUE(^(const id value) { clientId = value; }, jsonDict, TxTokenDetails.clientId);

    ARTTokenDetails *const o = [ARTTokenDetails new];
    [o initWithToken:token expires:expires issued:issued capability:capability clientId:clientId];
    return o;
}

+(ARTTokenParams *)readTokenParams: (NSDictionary *) jsonDict {
    __block NSString *clientId = nil;
    __block NSString *nonce = nil;
    
    ON_VALUE(^(const id value) { clientId = value; }, jsonDict, TxTokenParams.clientId);
    ON_VALUE(^(const id value) { nonce = value; }, jsonDict, TxTokenParams.nonce);
    
    ARTTokenParams *const o = [ARTTokenParams new];
    [o initWithClientId: clientId nonce: nonce];
    READ_VALUE(o, ttl, jsonDict, TxTokenParams.ttl);
    READ_VALUE(o, capability, jsonDict, TxTokenParams.capability);
    READ_VALUE(o, timestamp, jsonDict, TxTokenParams.timestamp);
    return o;
}

@end
