@import Ably;
#import "AblyFlutterReader.h"
#import "AblyFlutterClientOptions.h"
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

NS_ASSUME_NONNULL_BEGIN

typedef id (^AblyCodecDecoder)(NSDictionary * dictionary);

NS_ASSUME_NONNULL_END

@implementation AblyFlutterReader


+ (AblyCodecDecoder) getDecoder:(const NSString*)type {
    NSDictionary<NSString *, AblyCodecDecoder>* _handlers = @{
        [NSString stringWithFormat:@"%d", ablyMessageCodecType]: readAblyFlutterMessage,
        [NSString stringWithFormat:@"%d", ablyEventMessageCodecType ]: readAblyFlutterEventMessage,
        [NSString stringWithFormat:@"%d", clientOptionsCodecType]: readClientOptions,
        [NSString stringWithFormat:@"%d", messageExtrasCodecType]: readChannelMessageExtras,
        [NSString stringWithFormat:@"%d", messageCodecType]: readChannelMessage,
        [NSString stringWithFormat:@"%d", tokenDetailsCodecType]: readTokenDetails,
        [NSString stringWithFormat:@"%d", tokenRequestCodecType]: readTokenRequest,
        [NSString stringWithFormat:@"%d", restChannelOptionsCodecType]: readRestChannelOptions,
        [NSString stringWithFormat:@"%d", realtimeChannelOptionsCodecType]: readRealtimeChannelOptions,
        [NSString stringWithFormat:@"%d", restHistoryParamsCodecType]: readRestHistoryParams,
        [NSString stringWithFormat:@"%d", realtimeHistoryParamsCodecType]: readRealtimeHistoryParams,
        [NSString stringWithFormat:@"%d", restPresenceParamsCodecType]: readRestPresenceParams,
        [NSString stringWithFormat:@"%d", realtimePresenceParamsCodecType]: readRealtimePresenceParams,
        [NSString stringWithFormat:@"%d", messageDataCodecType]: readMessageData,
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

static AblyCodecDecoder readAblyFlutterMessage = ^AblyFlutterMessage*(NSDictionary *const dictionary) {
    AblyCodecDecoder decoder = [AblyFlutterReader getDecoder: [NSString stringWithFormat:@"%@", [dictionary objectForKey:TxAblyMessage_type]]];
    id message = [dictionary objectForKey:TxAblyMessage_message];
    if(decoder){
        message = decoder(message);
    }
    return [[AblyFlutterMessage alloc] initWithMessage:message handle: [dictionary objectForKey:TxAblyMessage_registrationHandle]];
};

static AblyCodecDecoder readAblyFlutterEventMessage = ^AblyFlutterEventMessage*(NSDictionary *const dictionary) {
    AblyCodecDecoder decoder = [AblyFlutterReader getDecoder: [NSString stringWithFormat:@"%@", [dictionary objectForKey:TxAblyEventMessage_type]]];
    NSString* eventName = [dictionary objectForKey:TxAblyEventMessage_eventName];
    id message = [dictionary objectForKey:TxAblyEventMessage_message];
    if(decoder){
        message = decoder(message);
    }
    return [[AblyFlutterEventMessage alloc] initWithEventName:eventName message:message];
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
#define ON_VALUE(BLOCK, DICTIONARY, JSON_KEY) { \
const id value = [DICTIONARY objectForKey: JSON_KEY]; \
if (value) { \
BLOCK(value); \
} \
}

#define READ_VALUE(OBJECT, PROPERTY, DICTIONARY, JSON_KEY) { \
ON_VALUE(^(const id value) { OBJECT.PROPERTY = value; }, DICTIONARY, JSON_KEY); \
}

/**
 Where an NSNumber has been decoded and the property to be set is BOOL.
 */
#define READ_BOOL(OBJECT, PROPERTY, DICTIONARY, JSON_KEY) { \
ON_VALUE(^(const id number) { OBJECT.PROPERTY = [number boolValue]; }, DICTIONARY, JSON_KEY); \
}

static AblyCodecDecoder readClientOptions = ^AblyFlutterClientOptions*(NSDictionary *const dictionary) {
    ARTClientOptions *const o = [ARTClientOptions new];

    // AuthOptions (super class of ClientOptions)
    READ_VALUE(o, authUrl, dictionary, TxClientOptions_authUrl);
    READ_VALUE(o, authMethod, dictionary, TxClientOptions_authMethod);
    READ_VALUE(o, key, dictionary, TxClientOptions_key);
    ON_VALUE(^(const id value) { o.tokenDetails = [AblyFlutterReader tokenDetailsFromDictionary: value]; }, dictionary, TxClientOptions_tokenDetails);
    READ_VALUE(o, authHeaders, dictionary, TxClientOptions_authHeaders);
    READ_VALUE(o, authParams, dictionary, TxClientOptions_authParams);
    READ_VALUE(o, queryTime, dictionary, TxClientOptions_queryTime);

    // ClientOptions
    READ_VALUE(o, clientId, dictionary, TxClientOptions_clientId);
    ON_VALUE(^(const id value) { o.logLevel = _logLevel(value); }, dictionary, TxClientOptions_logLevel);
    // TODO log handler
    READ_VALUE(o, tls, dictionary, TxClientOptions_tls);
    READ_VALUE(o, restHost, dictionary, TxClientOptions_restHost);
    READ_VALUE(o, realtimeHost, dictionary, TxClientOptions_realtimeHost);
    READ_BOOL(o, autoConnect, dictionary, TxClientOptions_autoConnect);
    READ_VALUE(o, useBinaryProtocol, dictionary, TxClientOptions_useBinaryProtocol);
    READ_VALUE(o, queueMessages, dictionary, TxClientOptions_queueMessages);
    READ_VALUE(o, echoMessages, dictionary, TxClientOptions_echoMessages);
    READ_VALUE(o, recover, dictionary, TxClientOptions_recover);
    READ_VALUE(o, environment, dictionary, TxClientOptions_environment);
    READ_VALUE(o, idempotentRestPublishing, dictionary, TxClientOptions_idempotentRestPublishing);
    READ_VALUE(o, fallbackHosts, dictionary, TxClientOptions_fallbackHosts);
    READ_VALUE(o, fallbackHostsUseDefault, dictionary, TxClientOptions_fallbackHostsUseDefault);
    ON_VALUE(^(const id value) {
        o.defaultTokenParams = [AblyFlutterReader tokenParamsFromDictionary: value];
    }, dictionary, TxClientOptions_defaultTokenParams);
    // Following properties not supported by Objective C library
    // useAuthToken, port, tlsPort, httpOpenTimeout, httpRequestTimeout,
    // httpMaxRetryCount, realtimeRequestTimeout, fallbackRetryTimeout,
    // channelRetryTimeout, transportParams, asyncHttpThreadpoolSize, pushFullWait
    // track @ https://github.com/ably/ably-flutter/issues/14

    [o addAgent:@"ably-flutter" version: FLUTTER_PACKAGE_PLUGIN_VERSION];

    AblyFlutterClientOptions *const co = [AblyFlutterClientOptions new];
    ON_VALUE(^(const id value) {
        [co initWithClientOptions: o hasAuthCallback: value];
    }, dictionary, TxClientOptions_hasAuthCallback);

    return co;
};

+(ARTTokenDetails *)tokenDetailsFromDictionary: (NSDictionary *) dictionary {
    __block NSString *token = nil;
    __block NSDate *expires = nil;
    __block NSDate *issued = nil;
    __block NSString *capability = nil;
    __block NSString *clientId = nil;
    
    ON_VALUE(^(const id value) { token = value; }, dictionary, TxTokenDetails_token);
    ON_VALUE(^(const id value) { expires = value; }, dictionary, TxTokenDetails_expires);
    ON_VALUE(^(const id value) { issued = value; }, dictionary, TxTokenDetails_issued);
    ON_VALUE(^(const id value) { capability = value; }, dictionary, TxTokenDetails_capability);
    ON_VALUE(^(const id value) { clientId = value; }, dictionary, TxTokenDetails_clientId);
    
    return [[ARTTokenDetails alloc] initWithToken:token expires:expires issued:issued capability:capability clientId:clientId];
}

+(ARTTokenParams *)tokenParamsFromDictionary: (NSDictionary *) dictionary {
    __block NSString *clientId = nil;
    __block NSString *nonce = nil;
    
    ON_VALUE(^(const id value) { clientId = value; }, dictionary, TxTokenParams_clientId);
    ON_VALUE(^(const id value) { nonce = value; }, dictionary, TxTokenParams_nonce);
    
    ARTTokenParams *const o = [[ARTTokenParams alloc] initWithClientId: clientId nonce: nonce];
    READ_VALUE(o, capability, dictionary, TxTokenParams_capability);
    READ_VALUE(o, timestamp, dictionary, TxTokenParams_timestamp);
    ON_VALUE(^(const id value) {
        o.ttl = [NSNumber numberWithDouble:[value doubleValue]/1000];
    }, dictionary, TxTokenParams_ttl);
    ON_VALUE(^(const id value) {
        o.timestamp = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxTokenParams_timestamp);
    return o;
}

static AblyCodecDecoder readRestChannelOptions = ^ARTChannelOptions*(NSDictionary *const dictionary) {
    ARTChannelOptions *const o = [ARTChannelOptions new];
    READ_VALUE(o, cipher, dictionary, TxRealtimeChannelOptions_cipher);
    return o;
};

static AblyCodecDecoder readRealtimeChannelOptions = ^ARTRealtimeChannelOptions*(NSDictionary *const dictionary) {
    __block ARTRealtimeChannelOptions* o;

    NSObject *const cipher = dictionary[TxRealtimeChannelOptions_cipher];
    if (cipher == nil) {
        o = [ARTRealtimeChannelOptions new];
    } else if ([cipher class] == [NSDictionary class]) {
        NSDictionary *const cipherDictionary = (NSDictionary *const) cipher;
        ARTCipherParams *const cipherParams = [[ARTCipherParams alloc] initWithAlgorithm: cipherDictionary[TxCipherParams_algorithm] key:cipherDictionary[TxCipherParams_key]];
        o = [[ARTRealtimeChannelOptions alloc] initWithCipher:cipherParams];
    } else if ([cipher class] == [NSString class]) {
        NSString *const key = (NSString *const) cipher;
        o = [[ARTRealtimeChannelOptions alloc] initWithCipherKey: (NSString *) key];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Cipher must be ARTCipherParams or key in the form of a NSString"];
    }

    READ_VALUE(o, params, dictionary, TxRealtimeChannelOptions_params);
    ON_VALUE(^(const id value) {
        NSArray* modes = (NSArray *)value;
        ARTChannelMode options = 0;
        if ([modes containsObject:TxEnumConstants_presence]) {
            options = options | ARTChannelModePresence;
        }
        if ([modes containsObject:TxEnumConstants_subscribe]) {
            options = options | ARTChannelModeSubscribe;
        }
        if ([modes containsObject:TxEnumConstants_publish]) {
            options = options | ARTChannelModePublish;
        }
        if ([modes containsObject:TxEnumConstants_presenceSubscribe]) {
            options = options | ARTChannelModePresenceSubscribe;
        }
        o.modes = options;
    }, dictionary, TxRealtimeChannelOptions_modes);
    return o;
};

static AblyCodecDecoder readChannelMessageExtras = ^id<ARTJsonCompatible>(NSDictionary *const dictionary) {
    return [dictionary objectForKey: TxMessageExtras_extras];
};

static AblyCodecDecoder readChannelMessage = ^ARTMessage*(NSDictionary *const dictionary) {
    ARTMessage *const o = [ARTMessage new];
    READ_VALUE(o, id, dictionary, TxMessage_id);
    READ_VALUE(o, name, dictionary, TxMessage_name);
    READ_VALUE(o, clientId, dictionary, TxMessage_clientId);
    READ_VALUE(o, encoding, dictionary, TxMessage_encoding);
    READ_VALUE(o, extras, dictionary, TxMessage_extras);
    READ_VALUE(o, data, dictionary, TxMessage_data);
    return o;
};

static AblyCodecDecoder readTokenDetails = ^ARTTokenDetails*(NSDictionary *const dictionary) {
    return [AblyFlutterReader tokenDetailsFromDictionary: dictionary];
};

static AblyCodecDecoder readTokenRequest = ^ARTTokenRequest*(NSDictionary *const dictionary) {
    __block NSString *mac = nil;
    __block NSString *nonce = nil;
    __block NSString *keyName = nil;

    ON_VALUE(^(const id value) { mac = value; }, dictionary, TxTokenRequest_mac);
    ON_VALUE(^(const id value) { nonce = value; }, dictionary, TxTokenRequest_nonce);
    ON_VALUE(^(const id value) { keyName = value; }, dictionary, TxTokenRequest_keyName);

    ARTTokenParams *const params = [AblyFlutterReader tokenParamsFromDictionary: dictionary];
    return [[ARTTokenRequest alloc] initWithTokenParams:params
                                              keyName:keyName
                                                nonce:nonce
                                                  mac:mac];
};

static AblyCodecDecoder readRestHistoryParams = ^ARTDataQuery*(NSDictionary *const dictionary) {
    ARTDataQuery *const o = [ARTDataQuery new];
    ON_VALUE(^(const id value) {
        o.start = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRestHistoryParams_start);
    ON_VALUE(^(const id value) {
        o.end = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRestHistoryParams_end);
    ON_VALUE(^(NSString const *value) {
        o.limit = [value integerValue];
    }, dictionary, TxRestHistoryParams_limit);
    ON_VALUE(^(NSString const *value) {
        if([@"forwards" isEqual: value]){
            o.direction = ARTQueryDirectionForwards;
        } else {
            o.direction = ARTQueryDirectionBackwards;
        }
    }, dictionary, TxRestHistoryParams_direction);
    return o;
};

static AblyCodecDecoder readRealtimeHistoryParams = ^ARTRealtimeHistoryQuery*(NSDictionary *const dictionary) {
    ARTRealtimeHistoryQuery *const o = [ARTRealtimeHistoryQuery new];
    ON_VALUE(^(const id value) {
        o.start = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRealtimeHistoryParams_start);
    ON_VALUE(^(const id value) {
        o.end = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRealtimeHistoryParams_end);
    ON_VALUE(^(NSString const *value) {
        o.limit = [value integerValue];
    }, dictionary, TxRealtimeHistoryParams_limit);
    ON_VALUE(^(NSString const *value) {
        if([@"forwards" isEqual: value]){
            o.direction = ARTQueryDirectionForwards;
        } else {
            o.direction = ARTQueryDirectionBackwards;
        }
    }, dictionary, TxRealtimeHistoryParams_direction);
    READ_VALUE(o, untilAttach, dictionary, TxRealtimeHistoryParams_untilAttach);
    return o;
};

static AblyCodecDecoder readRestPresenceParams = ^ARTPresenceQuery*(NSDictionary *const dictionary) {
    ARTPresenceQuery *const o = [ARTPresenceQuery new];
    ON_VALUE(^(NSString const *value) {
        o.limit = [value integerValue];
    }, dictionary, TxRestPresenceParams_limit);
    READ_VALUE(o, clientId, dictionary, TxRestPresenceParams_clientId);
    READ_VALUE(o, connectionId, dictionary, TxRestPresenceParams_connectionId);

    return o;
};

static AblyCodecDecoder readRealtimePresenceParams = ^ARTRealtimePresenceQuery*(NSDictionary *const dictionary) {
    ARTRealtimePresenceQuery *const o = [ARTRealtimePresenceQuery new];
    READ_VALUE(o, clientId, dictionary, TxRealtimePresenceParams_clientId);
    READ_VALUE(o, connectionId, dictionary, TxRealtimePresenceParams_connectionId);
    READ_VALUE(o, waitForSync, dictionary, TxRealtimePresenceParams_waitForSync);
    return o;
};

static AblyCodecDecoder readMessageData = ^id (NSDictionary *const dictionary) {
    return [dictionary objectForKey: TxMessage_data];
};

@end
