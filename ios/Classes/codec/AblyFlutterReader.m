@import Ably;
#import "AblyFlutterReader.h"
#import "AblyFlutterClientOptions.h"
#import "AblyFlutterMessage.h"
#import "AblyPlatformConstants.h"
#import <ably_flutter/ably_flutter-Swift.h>

static ARTLogLevel _logLevel(NSString *const logLevelString) {
    if ([logLevelString isEqualToString:TxLogLevelEnum_none]) return ARTLogLevelNone;
    if ([logLevelString isEqualToString:TxLogLevelEnum_verbose]) return ARTLogLevelVerbose;
    if ([logLevelString isEqualToString:TxLogLevelEnum_debug]) return ARTLogLevelDebug;
    if ([logLevelString isEqualToString:TxLogLevelEnum_info]) return ARTLogLevelInfo;
    if ([logLevelString isEqualToString:TxLogLevelEnum_warn]) return ARTLogLevelWarn;
    if ([logLevelString isEqualToString:TxLogLevelEnum_error]) return ARTLogLevelError;
    return ARTLogLevelWarn;
}

NS_ASSUME_NONNULL_BEGIN

typedef id (^AblyCodecDecoder)(NSDictionary * dictionary);

NS_ASSUME_NONNULL_END

@implementation AblyFlutterReader

+ (AblyCodecDecoder) getDecoder:(const NSString*)type {
    NSDictionary<NSString *, AblyCodecDecoder>* _handlers = @{
        [NSString stringWithFormat:@"%d", CodecTypeAblyMessage]: readAblyFlutterMessage,
        [NSString stringWithFormat:@"%d", CodecTypeAblyEventMessage ]: readAblyFlutterEventMessage,
        [NSString stringWithFormat:@"%d", CodecTypeClientOptions]: readClientOptions,
        [NSString stringWithFormat:@"%d", CodecTypeMessageExtras]: readChannelMessageExtras,
        [NSString stringWithFormat:@"%d", CodecTypeMessage]: readChannelMessage,
        [NSString stringWithFormat:@"%d", CodecTypeTokenDetails]: readTokenDetails,
        [NSString stringWithFormat:@"%d", CodecTypeTokenRequest]: readTokenRequest,
        [NSString stringWithFormat:@"%d", CodecTypeRestChannelOptions]: CryptoCodec.readRestChannelOptions,
        [NSString stringWithFormat:@"%d", CodecTypeRealtimeChannelOptions]: CryptoCodec.readRealtimeChannelOptions,
        [NSString stringWithFormat:@"%d", CodecTypeRestHistoryParams]: readRestHistoryParams,
        [NSString stringWithFormat:@"%d", CodecTypeRealtimeHistoryParams]: readRealtimeHistoryParams,
        [NSString stringWithFormat:@"%d", CodecTypeRestPresenceParams]: readRestPresenceParams,
        [NSString stringWithFormat:@"%d", CodecTypeRealtimePresenceParams]: readRealtimePresenceParams,
        [NSString stringWithFormat:@"%d", CodecTypeMessageData]: readMessageData,
        [NSString stringWithFormat:@"%d", CodecTypeCipherParams]: CryptoCodec.readCipherParams,
        [NSString stringWithFormat:@"%d", CodecTypeAuthOptions]: readAuthOptions,
        [NSString stringWithFormat:@"%d", CodecTypeTokenParams]: readTokenParams,
    };
    return _handlers[[NSString stringWithFormat:@"%@", type]];
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
    AblyCodecDecoder decoder = [AblyFlutterReader getDecoder:[NSString stringWithFormat:@"%@", dictionary[TxAblyMessage_type]]];
    id message = dictionary[TxAblyMessage_message];
    if(decoder){
        message = decoder(message);
    }
    return [[AblyFlutterMessage alloc] initWithMessage:message handle:dictionary[TxAblyMessage_registrationHandle]];
};

static AblyCodecDecoder readAblyFlutterEventMessage = ^AblyFlutterEventMessage*(NSDictionary *const dictionary) {
    AblyCodecDecoder decoder = [AblyFlutterReader getDecoder:[NSString stringWithFormat:@"%@", dictionary[TxAblyEventMessage_type]]];
    NSString* eventName = dictionary[TxAblyEventMessage_eventName];
    id message = dictionary[TxAblyEventMessage_message];
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
if (value && !([value isKindOfClass:[NSNull class]])) { \
BLOCK(value); \
} \
}

#define READ_VALUE(OBJECT, PROPERTY, DICTIONARY, JSON_KEY) { \
ON_VALUE(^(const id value) {if(!([value isKindOfClass:[NSNull class]])) OBJECT.PROPERTY = value; }, DICTIONARY, JSON_KEY); \
}

#define READ_URL(OBJECT, PROPERTY, DICTIONARY, JSON_KEY) { \
ON_VALUE(^(const id value) {if(!([value isKindOfClass:[NSNull class]])) OBJECT.PROPERTY = [NSURL URLWithString:value]; }, DICTIONARY, JSON_KEY); \
}

/**
 Where an NSNumber has been decoded and the property to be set is BOOL.
 */
#define READ_BOOL(OBJECT, PROPERTY, DICTIONARY, JSON_KEY) { \
ON_VALUE(^(const id number) {if(!([value isKindOfClass:[NSNull class]])) OBJECT.PROPERTY = [number boolValue]; }, DICTIONARY, JSON_KEY); \
}

static AblyCodecDecoder readClientOptions = ^AblyFlutterClientOptions*(NSDictionary *const dictionary) {
    ARTClientOptions *const clientOptions = [ARTClientOptions new];
    // AuthOptions (super class of ClientOptions)
    READ_URL(clientOptions, authUrl, dictionary, TxClientOptions_authUrl);
    READ_VALUE(clientOptions, authMethod, dictionary, TxClientOptions_authMethod);
    READ_VALUE(clientOptions, key, dictionary, TxClientOptions_key);
    ON_VALUE(^(const id value) { clientOptions.tokenDetails = [AblyFlutterReader tokenDetailsFromDictionary: value]; }, dictionary, TxClientOptions_tokenDetails);
    READ_VALUE(clientOptions, authHeaders, dictionary, TxClientOptions_authHeaders);
    READ_VALUE(clientOptions, authParams, dictionary, TxClientOptions_authParams);
    READ_VALUE(clientOptions, queryTime, dictionary, TxClientOptions_queryTime);

    // ClientOptions
    READ_VALUE(clientOptions, clientId, dictionary, TxClientOptions_clientId);
    ON_VALUE(^(const id value) { clientOptions.logLevel = _logLevel(value); }, dictionary, TxClientOptions_logLevel);
    // TODO log handler
    READ_VALUE(clientOptions, tls, dictionary, TxClientOptions_tls);
    READ_VALUE(clientOptions, restHost, dictionary, TxClientOptions_restHost);
    READ_VALUE(clientOptions, realtimeHost, dictionary, TxClientOptions_realtimeHost);
    READ_BOOL(clientOptions, autoConnect, dictionary, TxClientOptions_autoConnect);
    READ_VALUE(clientOptions, useBinaryProtocol, dictionary, TxClientOptions_useBinaryProtocol);
    READ_VALUE(clientOptions, queueMessages, dictionary, TxClientOptions_queueMessages);
    READ_VALUE(clientOptions, echoMessages, dictionary, TxClientOptions_echoMessages);
    READ_VALUE(clientOptions, recover, dictionary, TxClientOptions_recover);
    READ_VALUE(clientOptions, environment, dictionary, TxClientOptions_environment);
    READ_VALUE(clientOptions, idempotentRestPublishing, dictionary, TxClientOptions_idempotentRestPublishing);
    READ_VALUE(clientOptions, fallbackHosts, dictionary, TxClientOptions_fallbackHosts);
    READ_VALUE(clientOptions, fallbackHostsUseDefault, dictionary, TxClientOptions_fallbackHostsUseDefault);
    ON_VALUE(^(const id value) {
        clientOptions.transportParams = [AblyFlutterReader transportParamsFromDictionary: value];
    }, dictionary, TxClientOptions_transportParams);
    ON_VALUE(^(const id value) {
        clientOptions.defaultTokenParams = [AblyFlutterReader tokenParamsFromDictionary: value];
    }, dictionary, TxClientOptions_defaultTokenParams);
    // Following properties not supported by Objective C library
    // useAuthToken, port, tlsPort, httpOpenTimeout, httpRequestTimeout,
    // httpMaxRetryCount, realtimeRequestTimeout, fallbackRetryTimeout,
    // channelRetryTimeout, asyncHttpThreadpoolSize, pushFullWait
    // track @ https://github.com/ably/ably-flutter/issues/14

    NSMutableDictionary *const clientAgents = [[NSMutableDictionary alloc]init];
    [clientAgents setObject:FLUTTER_PACKAGE_PLUGIN_VERSION forKey:@"ably-flutter"];
    ON_VALUE(^(const id value) {
        [clientAgents setObject:value forKey:@"dart"];
    }, dictionary, TxClientOptions_dartVersion);

    clientOptions.agents = clientAgents;

    return  [[AblyFlutterClientOptions alloc]
             initWithClientOptions:clientOptions
             hasAuthCallback:dictionary[TxClientOptions_hasAuthCallback]];
};

static AblyCodecDecoder readAuthOptions = ^ARTAuthOptions*(NSDictionary *const dictionary) {
    ARTAuthOptions *const authOptions = [ARTAuthOptions new];
    READ_URL(authOptions, authUrl, dictionary, TxAuthOptions_authUrl);
    READ_VALUE(authOptions, authMethod, dictionary, TxAuthOptions_authMethod)
     
    ON_VALUE(^(const id value) { authOptions.tokenDetails = [AblyFlutterReader tokenDetailsFromDictionary: value]; }, dictionary, TxAuthOptions_tokenDetails);
    ;
    READ_VALUE(authOptions, key, dictionary, TxAuthOptions_key);
    
    READ_VALUE(authOptions, authHeaders, dictionary, TxAuthOptions_authHeaders);
    
    READ_VALUE(authOptions, authParams, dictionary, TxAuthOptions_authParams);
    
    READ_VALUE(authOptions, queryTime, dictionary, TxAuthOptions_queryTime);


    return authOptions;
};

static AblyCodecDecoder readTokenParams = ^ARTTokenParams*(NSDictionary *const dictionary) {
    ARTTokenParams *const tokenParams = [ARTTokenParams new];

    READ_VALUE(tokenParams, capability, dictionary, TxTokenParams_capability);
    READ_VALUE(tokenParams, clientId, dictionary, TxTokenParams_clientId)
    READ_VALUE(tokenParams, timestamp, dictionary, TxTokenParams_timestamp);
    READ_VALUE(tokenParams, ttl, dictionary, TxTokenParams_ttl);

    return tokenParams;
};


+(ARTTokenDetails *)tokenDetailsFromDictionary: (NSDictionary *) dictionary {
    NSString *token = nil;
    NSDate *expires = nil;
    NSDate *issued = nil;
    NSString *capability = nil;
    NSString *clientId = nil;

    if ([dictionary[TxTokenDetails_token] isKindOfClass: [NSString class]]) {
        token = dictionary[TxTokenDetails_token];
    }

    if ([dictionary[TxTokenDetails_expires] isKindOfClass: [NSNumber class]]) {
        NSNumber *const timeInMilliseconds = dictionary[TxTokenDetails_issued];
        expires = [NSDate dateWithTimeIntervalSince1970:timeInMilliseconds.doubleValue];
    }

    if ([dictionary[TxTokenDetails_issued] isKindOfClass: [NSNumber class]]) {
        NSNumber *const timeInMilliseconds = dictionary[TxTokenDetails_issued];
        issued = [NSDate dateWithTimeIntervalSince1970:timeInMilliseconds.doubleValue];
    }

    if ([dictionary[TxTokenDetails_capability] isKindOfClass: [NSString class]]) {
        capability = dictionary[TxTokenDetails_capability];
    }

    if ([dictionary[TxTokenDetails_clientId] isKindOfClass: [NSString class]]) {
        clientId = dictionary[TxTokenDetails_clientId];
    }

    return [[ARTTokenDetails alloc] initWithToken:token expires:expires issued:issued capability:capability clientId:clientId];
}

+(ARTTokenParams *)tokenParamsFromDictionary: (NSDictionary *) dictionary {
    __block NSString *clientId = nil;
    __block NSString *nonce = nil;
    
    ON_VALUE(^(const id value) { clientId = value; }, dictionary, TxTokenParams_clientId);
    ON_VALUE(^(const id value) { nonce = value; }, dictionary, TxTokenParams_nonce);
    
    ARTTokenParams *const tokenParams = [[ARTTokenParams alloc] initWithClientId: clientId nonce: nonce];
    READ_VALUE(tokenParams, capability, dictionary, TxTokenParams_capability);
    READ_VALUE(tokenParams, timestamp, dictionary, TxTokenParams_timestamp);
    ON_VALUE(^(const id value) {
        tokenParams.ttl = @([value doubleValue] / 1000);
    }, dictionary, TxTokenParams_ttl);
    ON_VALUE(^(const id value) {
        tokenParams.timestamp = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxTokenParams_timestamp);
    return tokenParams;
}


+(NSDictionary<NSString *, ARTStringifiable *> *)transportParamsFromDictionary: (NSDictionary *) dictionary {
    NSMutableDictionary<NSString *, ARTStringifiable *> *result = [NSMutableDictionary dictionary];

    for (NSString *key in dictionary) {
        NSString *value = dictionary[key];
        ARTStringifiable *stringifiable = [[ARTStringifiable alloc] initWithString:value];
        result[key] = stringifiable;
    }

    return [result copy];
}

static AblyCodecDecoder readChannelMessageExtras = ^id<ARTJsonCompatible>(NSDictionary *const dictionary) {
    return dictionary[TxMessageExtras_extras];
};

static AblyCodecDecoder readChannelMessage = ^ARTMessage*(NSDictionary *const dictionary) {
    ARTMessage *const message = [ARTMessage new];
    READ_VALUE(message, id, dictionary, TxMessage_id);
    READ_VALUE(message, name, dictionary, TxMessage_name);
    READ_VALUE(message, clientId, dictionary, TxMessage_clientId);
    READ_VALUE(message, encoding, dictionary, TxMessage_encoding);
    READ_VALUE(message, extras, dictionary, TxMessage_extras);
    READ_VALUE(message, data, dictionary, TxMessage_data);
    return message;
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
    ARTDataQuery *const query = [ARTDataQuery new];
    ON_VALUE(^(const id value) {
        query.start = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRestHistoryParams_start);
    ON_VALUE(^(const id value) {
        query.end = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRestHistoryParams_end);
    ON_VALUE(^(NSString const *value) {
        query.limit = [value integerValue];
    }, dictionary, TxRestHistoryParams_limit);
    ON_VALUE(^(NSString const *value) {
        if([@"forwards" isEqual: value]){
            query.direction = ARTQueryDirectionForwards;
        } else {
            query.direction = ARTQueryDirectionBackwards;
        }
    }, dictionary, TxRestHistoryParams_direction);
    return query;
};

static AblyCodecDecoder readRealtimeHistoryParams = ^ARTRealtimeHistoryQuery*(NSDictionary *const dictionary) {
    ARTRealtimeHistoryQuery *const query = [ARTRealtimeHistoryQuery new];
    ON_VALUE(^(const id value) {
        query.start = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRealtimeHistoryParams_start);
    ON_VALUE(^(const id value) {
        query.end = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
    }, dictionary, TxRealtimeHistoryParams_end);
    ON_VALUE(^(NSString const *value) {
        query.limit = [value integerValue];
    }, dictionary, TxRealtimeHistoryParams_limit);
    ON_VALUE(^(NSString const *value) {
        if([@"forwards" isEqual: value]){
            query.direction = ARTQueryDirectionForwards;
        } else {
            query.direction = ARTQueryDirectionBackwards;
        }
    }, dictionary, TxRealtimeHistoryParams_direction);
    READ_VALUE(query, untilAttach, dictionary, TxRealtimeHistoryParams_untilAttach);
    return query;
};

static AblyCodecDecoder readRestPresenceParams = ^ARTPresenceQuery*(NSDictionary *const dictionary) {
    ARTPresenceQuery *const query = [ARTPresenceQuery new];
    ON_VALUE(^(NSString const *value) {
        query.limit = [value integerValue];
    }, dictionary, TxRestPresenceParams_limit);
    READ_VALUE(query, clientId, dictionary, TxRestPresenceParams_clientId);
    READ_VALUE(query, connectionId, dictionary, TxRestPresenceParams_connectionId);

    return query;
};

static AblyCodecDecoder readRealtimePresenceParams = ^ARTRealtimePresenceQuery*(NSDictionary *const dictionary) {
    ARTRealtimePresenceQuery *const query = [ARTRealtimePresenceQuery new];
    READ_VALUE(query, clientId, dictionary, TxRealtimePresenceParams_clientId);
    READ_VALUE(query, connectionId, dictionary, TxRealtimePresenceParams_connectionId);
    READ_VALUE(query, waitForSync, dictionary, TxRealtimePresenceParams_waitForSync);
    return query;
};

static AblyCodecDecoder readMessageData = ^id (NSDictionary *const dictionary) {
    return dictionary[TxMessage_data];
};

@end
