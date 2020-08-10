@import Ably;
#import "AblyFlutterWriter.h"
#import "AblyFlutterMessage.h"
#import "AblyFlutterReader.h"
#import "AblyPlatformConstants.h"


NS_ASSUME_NONNULL_BEGIN

typedef NSDictionary * (^AblyCodecEncoder)(id toEncode);

NS_ASSUME_NONNULL_END


@implementation AblyFlutterWriter

+ (UInt8) getType:(id)value{
    if([value isKindOfClass:[AblyFlutterMessage class]]){
        return ablyMessageCodecType;
    }else if([value isKindOfClass:[ARTErrorInfo class]]){
        return errorInfoCodecType;
    }else if([value isKindOfClass:[ARTConnectionStateChange class]]){
        return connectionStateChangeCodecType;
    }else if([value isKindOfClass:[ARTChannelStateChange class]]){
        return channelStateChangeCodecType;
    }else if([value isKindOfClass:[ARTMessage class]]){
        return messageCodecType;
    }else if([value isKindOfClass:[ARTTokenParams class]]){
        return tokenParamsCodecType;
    }
    return 0;
}

+ (AblyCodecEncoder) getEncoder:(const NSString*)type {
    NSDictionary<NSString *, AblyCodecEncoder>* _handlers = @{
        [NSString stringWithFormat:@"%d", ablyMessageCodecType]: encodeAblyMessage,
        [NSString stringWithFormat:@"%d", errorInfoCodecType]: encodeErrorInfo,
        [NSString stringWithFormat:@"%d", connectionStateChangeCodecType]: encodeConnectionStateChange,
        [NSString stringWithFormat:@"%d", channelStateChangeCodecType]: encodeChannelStateChange,
        [NSString stringWithFormat:@"%d", messageCodecType]: encodeChannelMessage,
        [NSString stringWithFormat:@"%d", tokenParamsCodecType]: encodeTokenParams,
    };
    return [_handlers objectForKey:[NSString stringWithFormat:@"%@", type]];
}

- (void)writeValue:(id)value {
    UInt8 const type = [AblyFlutterWriter getType:value];
    if(type != 0){
        [self writeByte: type];
        AblyCodecEncoder encoder = [AblyFlutterWriter getEncoder: [NSString stringWithFormat:@"%d", type]];
        [self writeValue: encoder(value)];
        return;
    }
    [super writeValue:value];
}

#define WRITE_VALUE(DICTIONARY, JSON_KEY, VALUE) { \
if (VALUE) { \
[DICTIONARY setObject:VALUE forKey:JSON_KEY]; \
} \
}

#define WRITE_ENUM(DICTIONARY, JSON_KEY, ENUM_VALUE){ \
if (ENUM_VALUE) { \
WRITE_VALUE(DICTIONARY, JSON_KEY, [NSNumber numberWithInt:ENUM_VALUE]); \
} \
}

static AblyCodecEncoder encodeAblyMessage = ^NSMutableDictionary*(AblyFlutterMessage *const message) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_VALUE(dictionary, TxAblyMessage_registrationHandle, [message handle]);
    id value = [message message];
    UInt8 type = [AblyFlutterWriter getType:value];
    if(type != 0){
        AblyCodecEncoder encoder = [AblyFlutterWriter getEncoder: [NSString stringWithFormat:@"%d", type]];
        value = encoder(value);
        WRITE_VALUE(dictionary, TxAblyMessage_type, [NSNumber numberWithInt:type]);
    }
    WRITE_VALUE(dictionary, TxAblyMessage_message, value);
    return dictionary;
};

static AblyCodecEncoder encodeErrorInfo = ^NSMutableDictionary*(ARTErrorInfo *const e) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_VALUE(dictionary, TxErrorInfo_message, [e message]);
    WRITE_VALUE(dictionary, TxErrorInfo_statusCode, [e statusCode]?@([e statusCode]):nil);
    // code, href, requestId and cause - not available in ably-cocoa
    // track @ https://github.com/ably/ably-flutter/issues/14
    return dictionary;
};

static AblyCodecEncoder encodeConnectionStateChange = ^NSMutableDictionary*(ARTConnectionStateChange *const stateChange) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_ENUM(dictionary, TxConnectionStateChange_current, [stateChange current]);
    WRITE_ENUM(dictionary, TxConnectionStateChange_previous, [stateChange previous]);
    WRITE_ENUM(dictionary, TxConnectionStateChange_event, [stateChange event]);
    WRITE_VALUE(dictionary, TxConnectionStateChange_retryIn, [stateChange retryIn]?@((int)([stateChange retryIn] * 1000)):nil);
    WRITE_VALUE(dictionary, TxConnectionStateChange_reason, encodeErrorInfo([stateChange reason]));
    return dictionary;
};

static AblyCodecEncoder encodeChannelStateChange = ^NSMutableDictionary*(ARTChannelStateChange *const stateChange) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_ENUM(dictionary, TxChannelStateChange_current, [stateChange current]);
    WRITE_ENUM(dictionary, TxChannelStateChange_previous, [stateChange previous]);
    WRITE_ENUM(dictionary, TxChannelStateChange_event, [stateChange event]);
    WRITE_VALUE(dictionary, TxChannelStateChange_resumed, [stateChange resumed]?@([stateChange resumed]):nil);
    WRITE_VALUE(dictionary, TxChannelStateChange_reason, encodeErrorInfo([stateChange reason]));
    return dictionary;
};

static AblyCodecEncoder encodeChannelMessage = ^NSMutableDictionary*(ARTMessage *const message) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    
    WRITE_VALUE(dictionary, TxMessage_id, [message id]);
    WRITE_VALUE(dictionary, TxMessage_name, [message name]);
    WRITE_VALUE(dictionary, TxMessage_clientId, [message clientId]);
    WRITE_VALUE(dictionary, TxMessage_connectionId, [message connectionId]);
    WRITE_VALUE(dictionary, TxMessage_encoding, [message encoding]);
    WRITE_VALUE(dictionary, TxMessage_extras, [message extras]);
    WRITE_VALUE(dictionary, TxMessage_data, (NSObject *)[message data]);
        
    WRITE_VALUE(dictionary, TxMessage_timestamp,
                [message timestamp]?@((long)([[message timestamp] timeIntervalSince1970]*1000)):nil);

    return dictionary;
};

static AblyCodecEncoder encodeTokenParams = ^NSMutableDictionary*(ARTTokenParams *const params) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];

    WRITE_VALUE(dictionary, TxTokenParams_ttl, [params ttl]);
    WRITE_VALUE(dictionary, TxTokenParams_nonce, [params nonce]);
    WRITE_VALUE(dictionary, TxTokenParams_clientId, [params clientId]);
    WRITE_VALUE(dictionary, TxTokenParams_timestamp,
                [params timestamp]?@((long)([[params timestamp] timeIntervalSince1970]*1000)):nil);
    WRITE_VALUE(dictionary, TxTokenParams_capability, [params capability]);
    
    return dictionary;
};

@end
