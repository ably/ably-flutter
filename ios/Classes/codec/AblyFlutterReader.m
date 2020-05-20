#import "AblyFlutterReader.h"
#import "Ably.h"
#import "AblyFlutterMessage.h"
#import "AblyPlatformConstants.h"


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

@implementation AblyFlutterReader

-(id)readValueOfType:(const UInt8)type {
    switch (type) {
        case clientOptionsCodecType:
            return [self readClientOptions];
            
        case tokenDetailsCodecType:
            return [self readTokenDeatils];
            
        case ablyMessageCodecType:
            return [self readAblyFlutterMessage];
    }
    
    return [super readValueOfType:type];
}

-(AblyFlutterMessage *)readAblyFlutterMessage {
    NSNumber *const handle = [self readValue];
    const id message = [self readValue];
    return [[AblyFlutterMessage alloc] initWithHandle:handle message:message];
}

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
#define ON_VALUE(BLOCK) { \
    const id value = [self readValue]; \
    if (value) { \
        BLOCK(value); \
    } \
}

#define READ_VALUE(OBJECT, PROPERTY) { \
    ON_VALUE(^(const id value) { OBJECT.PROPERTY = value; }); \
}

/**
 Where an NSNumber has been decoded and the property to be set is BOOL.
 */
#define READ_BOOL(OBJECT, PROPERTY) { \
    ON_VALUE(^(const id number) { OBJECT.PROPERTY = [number boolValue]; }); \
}

-(ARTClientOptions *)readClientOptions {
    ARTClientOptions *const o = [ARTClientOptions new];
    
    // AuthOptions (super class of ClientOptions)
    READ_VALUE(o, authUrl);
    READ_VALUE(o, authMethod);
    READ_VALUE(o, key);
//    READ_VALUE(o, tokenDetails);
    ON_VALUE(^(const id value) { o.tokenDetails = value; });
    READ_VALUE(o, authHeaders);
    READ_VALUE(o, authParams);
    READ_VALUE(o, queryTime);
    [self readValue]; // TODO READ_VALUE(o, useAuthToken); // property not found

    // ClientOptions
    READ_VALUE(o, clientId);
    ON_VALUE(^(const id value) { o.logLevel = _logLevel(value); });
    //TODO log handler
    READ_VALUE(o, tls);
    READ_VALUE(o, restHost);
    READ_VALUE(o, realtimeHost);
    [self readValue]; // TODO READ_VALUE(o, port); // NSInteger
    [self readValue]; // TODO READ_VALUE(o, tlsPort); // NSInteger
    READ_BOOL(o, autoConnect);
    READ_VALUE(o, useBinaryProtocol);
    READ_VALUE(o, queueMessages);
    READ_VALUE(o, echoMessages);
    READ_VALUE(o, recover);
    READ_VALUE(o, environment);
    READ_VALUE(o, idempotentRestPublishing);
    [self readValue]; // TODO READ_VALUE(o, httpOpenTimeout); // NSTimeInterval
    [self readValue]; // TODO READ_VALUE(o, httpRequestTimeout); // NSTimeInterval
    [self readValue]; // TODO READ_VALUE(o, httpMaxRetryCount); // NSUInteger
    [self readValue]; // TODO READ_VALUE(o, realtimeRequestTimeout); // NSTimeInterval
    READ_VALUE(o, fallbackHosts);
    READ_VALUE(o, fallbackHostsUseDefault);
    [self readValue]; // TODO READ_VALUE(o, fallbackRetryTimeout); // property not found
    READ_VALUE(o, defaultTokenParams);
    [self readValue]; // TODO READ_VALUE(o, channelRetryTimeout); // NSTimeInterval
    [self readValue]; // TODO READ_VALUE(o, transportParams); // property not found
    //    [self readValue]; // TODO READ_VALUE(o, asyncHttpThreadpoolSize); // property not found
    //    READ_VALUE(o, pushFullWait);
    
    return o;
}


-(ARTTokenDetails *)readTokenDeatils {
    __block NSString *token = nil;
    __block NSDate *expires = nil;
    __block NSDate *issued = nil;
    __block NSString *capability = nil;
    __block NSString *clientId = nil;
    
    ON_VALUE(^(const id value) { token = value; })
    ON_VALUE(^(const id value) { expires = value; })
    ON_VALUE(^(const id value) { issued = value; })
    ON_VALUE(^(const id value) { capability = value; })
    ON_VALUE(^(const id value) { clientId = value; })
    
    ARTTokenDetails *const o = [ARTTokenDetails new];
    [o initWithToken:token expires:expires issued:issued capability:capability clientId:clientId];
    return o;
}

@end
