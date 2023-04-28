@import Ably;
@import UserNotifications;
#import <ably_flutter/ably_flutter-Swift.h>
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
        return CodecTypeAblyMessage;
    }else if([value isKindOfClass:[ARTErrorInfo class]]){
        return CodecTypeErrorInfo;
    }else if([value isKindOfClass:[ARTConnectionStateChange class]]){
        return CodecTypeConnectionStateChange;
    }else if([value isKindOfClass:[ARTChannelStateChange class]]){
        return CodecTypeChannelStateChange;
    }else if([value isKindOfClass:[ARTMessage class]]){
        return CodecTypeMessage;
    }else if([value isKindOfClass:[ARTPresenceMessage class]]){
        return CodecTypePresenceMessage;
    } else if ([value isKindOfClass:[ARTTokenRequest class]]){
        return CodecTypeTokenRequest;
    }else if([value isKindOfClass:[ARTTokenParams class]]){
        return CodecTypeTokenParams;
    }else if([value isKindOfClass:[ARTPaginatedResult class]]){
        return CodecTypePaginatedResult;
    } else if ([value isKindOfClass:[ARTLocalDevice class]]) {
        // Check for ARTLocalDevice before ARTLocalDevice, since ARTLocalDevice extends ARTDeviceDetails.
        // If CodecTypeDeviceDetails was used first, the ARTLocalDevice fields won't be serialized.
        return CodecTypeLocalDevice;
    } else if([value isKindOfClass:[ARTDeviceDetails class]]) {
        return CodecTypeDeviceDetails;
    } else if ([value isKindOfClass:[ARTPushChannelSubscription class]]) {
        return CodecTypePushChannelSubscription;
    } else if ([value isKindOfClass:[UNNotificationSettings class]]) {
        return CodecTypeUnNotificationSettings;
    } else if ([value isKindOfClass:[RemoteMessage class]]) {
        return CodecTypeRemoteMessage;
    } else if ([value isKindOfClass:[ARTRealtimeChannelOptions class]]) {
        return CodecTypeRealtimeChannelOptions;
    } else if ([value isKindOfClass:[ARTChannelOptions class]]) {
        return CodecTypeRestChannelOptions;
    } else if ([value isKindOfClass:[ARTCipherParams class]]) {
        return CodecTypeCipherParams;
    } else if ([value isKindOfClass:[ARTTokenDetails class]]) {
        return CodecTypeTokenDetails;
    }
    return 0;
}

+ (AblyCodecEncoder) getEncoder:(const NSString*)type {
    NSDictionary<NSString *, AblyCodecEncoder>* _handlers = @{
        [NSString stringWithFormat:@"%d", CodecTypeAblyMessage]: encodeAblyMessage,
        [NSString stringWithFormat:@"%d", CodecTypeErrorInfo]: encodeErrorInfo,
        [NSString stringWithFormat:@"%d", CodecTypeConnectionStateChange]: encodeConnectionStateChange,
        [NSString stringWithFormat:@"%d", CodecTypeChannelStateChange]: encodeChannelStateChange,
        [NSString stringWithFormat:@"%d", CodecTypeMessage]: encodeChannelMessage,
        [NSString stringWithFormat:@"%d", CodecTypePresenceMessage]: encodePresenceMessage,
        [NSString stringWithFormat:@"%d", CodecTypeTokenParams]: encodeTokenParams,
        [NSString stringWithFormat:@"%d", CodecTypePaginatedResult]: encodePaginatedResult,
        [NSString stringWithFormat:@"%d", CodecTypeDeviceDetails]: PushNotificationEncoders.encodeDeviceDetails,
        [NSString stringWithFormat:@"%d", CodecTypeLocalDevice]: PushNotificationEncoders.encodeLocalDevice,
        [NSString stringWithFormat:@"%d", CodecTypePushChannelSubscription]: PushNotificationEncoders.encodePushChannelSubscription,
        [NSString stringWithFormat:@"%d", CodecTypeUnNotificationSettings]: PushNotificationEncoders.encodeUNNotificationSettings,
        [NSString stringWithFormat:@"%d", CodecTypeRemoteMessage]: PushNotificationEncoders.encodeRemoteMessage,
        [NSString stringWithFormat:@"%d", CodecTypeCipherParams]: CryptoCodec.encodeCipherParams,
        [NSString stringWithFormat:@"%d", CodecTypeTokenDetails]: encodeTokenDetails,
        [NSString stringWithFormat:@"%d", CodecTypeTokenRequest]: encodeTokenRequest,
    };
    return [_handlers objectForKey:[NSString stringWithFormat:@"%@", type]];
}

- (void)writeValue:(id)value {
    UInt8 const type = [AblyFlutterWriter getType:value];
    if(type != 0){
        [self writeByte: type];
        AblyCodecEncoder encoder = [AblyFlutterWriter getEncoder: [NSString stringWithFormat:@"%d", type]];
        id encoded = encoder(value);
        [self writeValue: encoded];
        return;
    }
    [super writeValue:value];
}

#define WRITE_VALUE(DICTIONARY, JSON_KEY, VALUE) { \
if ( (VALUE) != nil ) { \
[DICTIONARY setObject:VALUE forKey:JSON_KEY]; \
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

+(NSString *) encodeConnectionState: (ARTRealtimeConnectionState) state {
    switch (state) {
        case ARTRealtimeInitialized:
            return TxEnumConstants_initialized;
        case ARTRealtimeConnecting:
            return TxEnumConstants_connecting;
        case ARTRealtimeConnected:
            return TxEnumConstants_connected;
        case ARTRealtimeDisconnected:
            return TxEnumConstants_disconnected;
        case ARTRealtimeSuspended:
            return TxEnumConstants_suspended;
        case ARTRealtimeClosing:
            return TxEnumConstants_closing;
        case ARTRealtimeClosed:
            return TxEnumConstants_closed;
        case ARTRealtimeFailed:
            return TxEnumConstants_failed;
    }
};

+(NSString *) encodeConnectionEvent: (ARTRealtimeConnectionEvent) event {
    switch(event) {
        case ARTRealtimeConnectionEventInitialized:
            return TxEnumConstants_initialized;
        case ARTRealtimeConnectionEventConnecting:
            return TxEnumConstants_connecting;
        case ARTRealtimeConnectionEventConnected:
            return TxEnumConstants_connected;
        case ARTRealtimeConnectionEventDisconnected:
            return TxEnumConstants_disconnected;
        case ARTRealtimeConnectionEventSuspended:
            return TxEnumConstants_suspended;
        case ARTRealtimeConnectionEventClosing:
            return TxEnumConstants_closing;
        case ARTRealtimeConnectionEventClosed:
            return TxEnumConstants_closed;
        case ARTRealtimeConnectionEventFailed:
            return TxEnumConstants_failed;
        case ARTRealtimeConnectionEventUpdate:
            return TxEnumConstants_update;
    }
}


+(NSString *) encodeChannelState: (ARTRealtimeChannelState) event {
    switch(event) {
        case ARTRealtimeChannelInitialized:
            return TxEnumConstants_initialized;
        case ARTRealtimeChannelAttaching:
            return TxEnumConstants_attaching;
        case ARTRealtimeChannelAttached:
            return TxEnumConstants_attached;
        case ARTRealtimeChannelDetaching:
            return TxEnumConstants_detaching;
        case ARTRealtimeChannelDetached:
            return TxEnumConstants_detached;
        case ARTRealtimeChannelSuspended:
            return TxEnumConstants_suspended;
        case ARTRealtimeChannelFailed:
            return TxEnumConstants_failed;
    }
}

+(NSString *) encodeChannelEvent: (ARTChannelEvent) event {
    switch(event) {
        case ARTChannelEventInitialized:
            return TxEnumConstants_initialized;
        case ARTChannelEventAttaching:
            return TxEnumConstants_attaching;
        case ARTChannelEventAttached:
            return TxEnumConstants_attached;
        case ARTChannelEventDetaching:
            return TxEnumConstants_detaching;
        case ARTChannelEventDetached:
            return TxEnumConstants_detached;
        case ARTChannelEventSuspended:
            return TxEnumConstants_suspended;
        case ARTChannelEventFailed:
            return TxEnumConstants_failed;
        case ARTChannelEventUpdate:
            return TxEnumConstants_update;
    }
}

static AblyCodecEncoder encodeConnectionStateChange = ^NSMutableDictionary*(ARTConnectionStateChange *const stateChange) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_VALUE(dictionary,
                TxConnectionStateChange_current,
                [AblyFlutterWriter encodeConnectionState: [stateChange current]]);
    WRITE_VALUE(dictionary,
                TxConnectionStateChange_previous,
                [AblyFlutterWriter encodeConnectionState: [stateChange previous]]);
    WRITE_VALUE(dictionary,
                TxConnectionStateChange_event,
                [AblyFlutterWriter encodeConnectionEvent: [stateChange event]]);
    WRITE_VALUE(dictionary, TxConnectionStateChange_retryIn, [stateChange retryIn]?@((int)([stateChange retryIn] * 1000)):nil);
    WRITE_VALUE(dictionary, TxConnectionStateChange_reason, encodeErrorInfo([stateChange reason]));
    return dictionary;
};

static AblyCodecEncoder encodeChannelStateChange = ^NSMutableDictionary*(ARTChannelStateChange *const stateChange) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    WRITE_VALUE(dictionary,
                TxChannelStateChange_current,
                [AblyFlutterWriter encodeChannelState: [stateChange current]]);
    WRITE_VALUE(dictionary,
                TxChannelStateChange_previous,
                [AblyFlutterWriter encodeChannelState: [stateChange previous]]);
    WRITE_VALUE(dictionary,
                TxChannelStateChange_event,
                [AblyFlutterWriter encodeChannelEvent: [stateChange event]]);

    WRITE_VALUE(dictionary, TxChannelStateChange_resumed, [NSNumber numberWithBool: [stateChange resumed]]);
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

+(NSString *) encodePresenceAction: (ARTPresenceAction) action {
    switch(action) {
        case ARTPresenceAbsent:
            return TxEnumConstants_absent;
        case ARTPresencePresent:
            return TxEnumConstants_present;
        case ARTPresenceEnter:
            return TxEnumConstants_enter;
        case ARTPresenceLeave:
            return TxEnumConstants_leave;
        case ARTPresenceUpdate:
            return TxEnumConstants_update;
    }
}

static AblyCodecEncoder encodePresenceMessage = ^NSMutableDictionary*(ARTPresenceMessage *const message) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    
    WRITE_VALUE(dictionary, TxPresenceMessage_id, [message id]);
    WRITE_VALUE(dictionary,
                TxPresenceMessage_action,
                [AblyFlutterWriter encodePresenceAction: [message action]]);
    WRITE_VALUE(dictionary, TxPresenceMessage_clientId, [message clientId]);
    WRITE_VALUE(dictionary, TxPresenceMessage_data, (NSObject *)[message data]);
    WRITE_VALUE(dictionary, TxPresenceMessage_connectionId, [message connectionId]);
    WRITE_VALUE(dictionary, TxPresenceMessage_encoding, [message encoding]);
    WRITE_VALUE(dictionary, TxPresenceMessage_extras, [message extras]);
    
    WRITE_VALUE(dictionary, TxPresenceMessage_timestamp,
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

static AblyCodecEncoder encodeTokenRequest = ^NSMutableDictionary*(ARTTokenRequest *const tokenRequest) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    
    WRITE_VALUE(dictionary, TxTokenRequest_ttl, [tokenRequest ttl]);
    WRITE_VALUE(dictionary, TxTokenRequest_nonce, [tokenRequest nonce]);
    WRITE_VALUE(dictionary, TxTokenRequest_clientId, [tokenRequest clientId]);
    WRITE_VALUE(dictionary, TxTokenRequest_timestamp,
                [tokenRequest timestamp]?@((long)([[tokenRequest timestamp] timeIntervalSince1970]*1000)):nil);
    WRITE_VALUE(dictionary, TxTokenRequest_capability, [tokenRequest capability]);
    WRITE_VALUE(dictionary, TxTokenRequest_mac, [tokenRequest mac]);
    WRITE_VALUE(dictionary, TxTokenRequest_keyName, [tokenRequest keyName]);
    
    return dictionary;
};

static AblyCodecEncoder encodeTokenDetails = ^NSMutableDictionary*(ARTTokenDetails *const details) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    
    WRITE_VALUE(dictionary, TxTokenDetails_token, [details token]);

    WRITE_VALUE(dictionary, TxTokenDetails_issued, [details issued]?@((long)([[details issued] timeIntervalSince1970]*1000)):nil);
    WRITE_VALUE(dictionary, TxTokenDetails_expires, [details expires]?@((long)([[details expires] timeIntervalSince1970]*1000)):nil);
    WRITE_VALUE(dictionary, TxTokenDetails_clientId, [details clientId]);
    WRITE_VALUE(dictionary, TxTokenDetails_capability, [details capability]);
   
    return dictionary;
};

static AblyCodecEncoder encodePaginatedResult = ^NSMutableDictionary*(ARTPaginatedResult *const result) {
    NSMutableDictionary<NSString *, NSObject *> *dictionary = [[NSMutableDictionary alloc] init];
    NSArray* items = [result items];
    if([items count] > 0){
        UInt8 type = [AblyFlutterWriter getType:items[0]];
        if(type != 0){
            AblyCodecEncoder encoder = [AblyFlutterWriter getEncoder: [NSString stringWithFormat:@"%d", type]];
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:[items count]];
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [result addObject: encoder(obj)];
            }];
            WRITE_VALUE(dictionary, TxPaginatedResult_type, [NSNumber numberWithInt:type]);
            WRITE_VALUE(dictionary, TxPaginatedResult_items, result);
        }
    }
    WRITE_VALUE(dictionary, TxPaginatedResult_hasNext, @([result hasNext]));
    
    return dictionary;
};

@end
