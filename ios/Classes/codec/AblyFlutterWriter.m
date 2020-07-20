#import "AblyFlutterWriter.h"
#import "Ably.h"
#import "ARTTypes.h"
#import "AblyFlutterMessage.h"
#import "AblyFlutterReader.h"
#import "AblyPlatformConstants.h"


@implementation AblyFlutterWriter

- (void)writeValue:(id)value {
    if([value isKindOfClass:[ARTErrorInfo class]]){
        [self writeByte:errorInfoCodecType];
        [self writeValue:[self encodeErrorInfo: value]];
        return;
    }else if([value isKindOfClass:[ARTConnectionStateChange class]]){
        [self writeByte:connectionStateChangeCodecType];
        [self writeValue: [self encodeConnectionStateChange: value]];
        return;
    }else if([value isKindOfClass:[ARTChannelStateChange class]]){
        [self writeByte:channelStateChangeCodecType];
        [self writeValue: [self encodeChannelStateChange: value]];
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

- (NSMutableDictionary<NSString *, NSObject *> *) encodeErrorInfo:(ARTErrorInfo *const) e{
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_VALUE(dictionary, TxErrorInfo_message, [e message]);
    WRITE_VALUE(dictionary, TxErrorInfo_statusCode, @([e statusCode]));
    // code, href, requestId and cause - not available in ably-cocoa
    // track @ https://github.com/ably/ably-flutter/issues/14
    return dictionary;
}

- (NSDictionary *) encodeConnectionStateChange:(ARTConnectionStateChange *const) stateChange{
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_ENUM(dictionary, TxConnectionStateChange_current, [stateChange current]);
    WRITE_ENUM(dictionary, TxConnectionStateChange_previous, [stateChange previous]);
    WRITE_ENUM(dictionary, TxConnectionStateChange_event, [stateChange event]);
    WRITE_VALUE(dictionary, TxConnectionStateChange_retryIn, @((int)([stateChange retryIn] * 1000)));
    WRITE_VALUE(dictionary, TxConnectionStateChange_reason, [self encodeErrorInfo: [stateChange reason]]);
    return dictionary;
}

- (NSDictionary *) encodeChannelStateChange:(ARTChannelStateChange *const) stateChange{
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_ENUM(dictionary, TxChannelStateChange_current, [stateChange current]);
    WRITE_ENUM(dictionary, TxChannelStateChange_previous, [stateChange previous]);
    WRITE_ENUM(dictionary, TxChannelStateChange_event, [stateChange event]);
    WRITE_VALUE(dictionary, TxChannelStateChange_resumed, @([stateChange resumed]));
    WRITE_VALUE(dictionary, TxChannelStateChange_reason, [self encodeErrorInfo: [stateChange reason]]);
    return dictionary;
}


@end
