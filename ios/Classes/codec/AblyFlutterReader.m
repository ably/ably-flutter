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

typedef id (^AblyCodecDecoder)(NSDictionary * jsonDict);

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
    AblyCodecDecoder decoder = [AblyFlutterReader getDecoder: [NSString stringWithFormat:@"%@", [jsonDict objectForKey:@"type"]]];
    id message = [jsonDict objectForKey:@"message"];
    if(decoder){
        message = decoder(message);
    }
    return [[AblyFlutterMessage alloc] initWithHandle:[jsonDict objectForKey:@"registrationHandle"] message:message];
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

    if([jsonDict objectForKey:@"message"]) o.authUrl = [jsonDict objectForKey:@"message"];

    // AuthOptions (super class of ClientOptions)
    READ_VALUE(o, authUrl, jsonDict, @"authUrl");
    READ_VALUE(o, authMethod, jsonDict, @"authMethod");
    READ_VALUE(o, key, jsonDict, @"key");
    ON_VALUE(^(const id value) { o.tokenDetails = [AblyFlutterReader readTokenDetails: value]; }, jsonDict, @"tokenDetails");
    READ_VALUE(o, authHeaders, jsonDict, @"authHeaders");
    READ_VALUE(o, authParams, jsonDict, @"authParams");
    READ_VALUE(o, queryTime, jsonDict, @"queryTime");

    // ClientOptions
    READ_VALUE(o, clientId, jsonDict, @"clientId");
    ON_VALUE(^(const id value) { o.logLevel = _logLevel(value); }, jsonDict, @"logLevel");
    //TODO log handler
    READ_VALUE(o, tls, jsonDict, @"tls");
    READ_VALUE(o, restHost, jsonDict, @"restHost");
    READ_VALUE(o, realtimeHost, jsonDict, @"realtimeHost");
    READ_BOOL(o, autoConnect, jsonDict, @"autoConnect");
    READ_VALUE(o, useBinaryProtocol, jsonDict, @"useBinaryProtocol");
    READ_VALUE(o, queueMessages, jsonDict, @"queueMessages");
    READ_VALUE(o, echoMessages, jsonDict, @"echoMessages");
    READ_VALUE(o, recover, jsonDict, @"recover");
    READ_VALUE(o, environment, jsonDict, @"environment");
    READ_VALUE(o, idempotentRestPublishing, jsonDict, @"idempotentRestPublishing");
    READ_VALUE(o, fallbackHosts, jsonDict, @"fallbackHosts");
    READ_VALUE(o, fallbackHostsUseDefault, jsonDict, @"fallbackHostsUseDefault");
    ON_VALUE(^(const id value) { o.defaultTokenParams = [AblyFlutterReader readTokenParams: value]; }, jsonDict, @"defaultTokenParams");
    READ_VALUE(o, defaultTokenParams, jsonDict, @"defaultTokenParams");
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
    
    ON_VALUE(^(const id value) { token = value; }, jsonDict, @"token");
    ON_VALUE(^(const id value) { expires = value; }, jsonDict, @"expires");
    ON_VALUE(^(const id value) { issued = value; }, jsonDict, @"issued");
    ON_VALUE(^(const id value) { capability = value; }, jsonDict, @"capability");
    ON_VALUE(^(const id value) { clientId = value; }, jsonDict, @"clientId");

    ARTTokenDetails *const o = [ARTTokenDetails new];
    [o initWithToken:token expires:expires issued:issued capability:capability clientId:clientId];
    return o;
}

+(ARTTokenParams *)readTokenParams: (NSDictionary *) jsonDict {
    __block NSString *clientId = nil;
    __block NSString *nonce = nil;
    
    ON_VALUE(^(const id value) { clientId = value; }, jsonDict, @"clientId");
    ON_VALUE(^(const id value) { nonce = value; }, jsonDict, @"nonce");
    
    ARTTokenParams *const o = [ARTTokenParams new];
    [o initWithClientId: clientId nonce: nonce];
    READ_VALUE(o, ttl, jsonDict, @"ttl");
    READ_VALUE(o, capability, jsonDict, @"capability");
    READ_VALUE(o, timestamp, jsonDict, @"timestamp");
    return o;
}

@end
