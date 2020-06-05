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

#define WRITE_VALUE(JSON_DICT, JSON_KEY, VALUE) { \
    if (VALUE) { \
        [JSON_DICT setObject:VALUE forKey:JSON_KEY]; \
    } \
}

#define WRITE_ENUM(JSON_DICT, JSON_KEY, ENUM_VALUE){ \
    if (ENUM_VALUE) { \
        WRITE_VALUE(JSON_DICT, JSON_KEY, [NSNumber numberWithInt:ENUM_VALUE]); \
    } \
}

- (NSMutableDictionary<NSString *, NSObject *> *) encodeErrorInfo:(ARTErrorInfo *const) e{
    NSMutableDictionary<NSString *, NSObject *> *jsonDict;
    WRITE_VALUE(jsonDict, TxErrorInfo_message, [e message]);
    WRITE_VALUE(jsonDict, TxErrorInfo_statusCode, @([e statusCode]));
    // code, href, requestId and cause - not available in ably-cocoa
    // track @ https://github.com/ably/ably-flutter/issues/14
    return jsonDict;
}

- (NSDictionary *) encodeConnectionStateChange:(ARTConnectionStateChange *const) stateChange{
    NSMutableDictionary<NSString *, NSObject *> *jsonDict = [[NSMutableDictionary alloc] init];
    WRITE_ENUM(jsonDict, TxConnectionStateChange_current, [stateChange current]);
    WRITE_ENUM(jsonDict, TxConnectionStateChange_previous, [stateChange previous]);
    WRITE_ENUM(jsonDict, TxConnectionStateChange_event, [stateChange event]);
    WRITE_VALUE(jsonDict, TxConnectionStateChange_retryIn, @((int)([stateChange retryIn] * 1000)));
    WRITE_VALUE(jsonDict, TxConnectionStateChange_reason, [self encodeErrorInfo: [stateChange reason]]);
    return jsonDict;
}

- (NSDictionary *) encodeChannelStateChange:(ARTChannelStateChange *const) stateChange{
    NSMutableDictionary<NSString *, NSObject *> *jsonDict;
    WRITE_ENUM(jsonDict, TxChannelStateChange_current, [stateChange current]);
    WRITE_ENUM(jsonDict, TxChannelStateChange_previous, [stateChange previous]);
    WRITE_ENUM(jsonDict, TxChannelStateChange_event, [stateChange event]);
    WRITE_VALUE(jsonDict, TxChannelStateChange_resumed, @([stateChange resumed]));
    WRITE_VALUE(jsonDict, TxChannelStateChange_reason, [self encodeErrorInfo: [stateChange reason]]);
    return jsonDict;
}


@end
