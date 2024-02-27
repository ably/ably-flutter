@import Ably.ARTRealtime;

#import "AblyFlutterStreamHandler.h"
#import "AblyFlutter.h"
#import "AblyFlutterMessage.h"
#import "codec/AblyPlatformConstants.h"

@implementation _AblyConnectionStateChange

- (instancetype)initWithStateChange:(ARTConnectionStateChange *)stateChange connectionId:(NSString *)connectionId connectionKey:(NSString *)connectionKey {
    self = [super init];
    if (self) {
        _value = stateChange;
        _connectionId = connectionId;
        _connectionKey = connectionKey;
    }
    return self;
}

@end

@implementation AblyFlutterStreamHandler{
    ARTEventListener *listener;
}

@synthesize instanceStore = _instanceStore;

- (instancetype)init{
    _instanceStore = [AblyInstanceStore sharedInstance];
    return self;
}

- (nullable FlutterError *)onListenWithArguments:(nullable id)arguments eventSink:(FlutterEventSink)eventSink {
    [self startListening:arguments emitter:eventSink];
    return nil;
}

- (nullable FlutterError *)onCancelWithArguments:(nullable id)arguments {
    [self cancelListening:arguments];
    return nil;
}

/// Additional type checks were introduced in all listeners due wrong types of object being emitted
/// See https://github.com/ably/ably-flutter/issues/355
- (void) startListening:(AblyFlutterMessage *const)message emitter:(FlutterEventSink)emitter {
    AblyFlutterEventMessage *const eventMessage = message.message;
    NSNumber *const handle = message.handle;
    NSString *const eventName = eventMessage.eventName;
    @try {
        if ([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
            ARTRealtime *const realtime = [_instanceStore realtimeFrom:handle];
            listener = [realtime.connection  on: ^(ARTConnectionStateChange * const stateChange) {
                if(![stateChange isKindOfClass:[ARTConnectionStateChange class]]) {
                    emitter([FlutterError errorWithCode:@"AblyFlutterStreamHandler.startListening"
                             message:[NSString stringWithFormat:@"Expected ARTConnectionStateChange but received %@", [stateChange class]]
                             details:eventName
                    ]);
                } else {
                    _AblyConnectionStateChange * const _stateChange = [[_AblyConnectionStateChange alloc] initWithStateChange:stateChange connectionId:realtime.connection.id connectionKey:realtime.connection.key];
                    emitter(_stateChange);
                }
            }];
        } else if ([AblyPlatformMethod_onRealtimeChannelStateChanged isEqual: eventName]) {
            NSAssert(eventMessage.message, @"event message is missing");
            NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
            ARTRealtime *const realtime = [_instanceStore realtimeFrom:handle];
            
            NSString *const channelName = (NSString*) eventPayload[TxTransportKeys_channelName];
            ARTRealtimeChannel *const channel  = [realtime.channels get:channelName];
            
            listener = [channel on: ^(ARTChannelStateChange * const stateChange) {
                if(![stateChange isKindOfClass:[ARTChannelStateChange class]]) {
                    emitter([FlutterError errorWithCode:@"AblyFlutterStreamHandler.startListening"
                                message:[NSString stringWithFormat:@"Expected ARTChannelStateChange but received %@", [stateChange class]]
                                details:[NSString stringWithFormat:@"Event %@", eventName]
                    ]);
                } else {
                    emitter(stateChange);
                }
            }];
        } else if ([AblyPlatformMethod_onRealtimeChannelMessage isEqual: eventName]) {
            NSAssert(eventMessage.message, @"event message is missing");
            NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
            ARTRealtime *const realtime = [_instanceStore realtimeFrom:handle];
            
            NSString *const channelName = (NSString*) eventPayload[TxTransportKeys_channelName];
            ARTRealtimeChannel *const channel  = [realtime.channels get:channelName];
            
            listener = [channel subscribe: ^(ARTMessage * const message) {
                if(![message isKindOfClass:[ARTMessage class]]) {
                    emitter([FlutterError errorWithCode:@"AblyFlutterStreamHandler.startListening"
                                message:[NSString stringWithFormat:@"Expected ARTMessage but received %@", [message class]]
                                details:[NSString stringWithFormat:@"Event %@", eventName]
                    ]);
                } else {
                    emitter(message);
                }
            }];
        } else if ([AblyPlatformMethod_onRealtimePresenceMessage isEqual: eventName]) {
            NSAssert(eventMessage.message, @"event message is missing");
            NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
            ARTRealtime *const realtime = [_instanceStore realtimeFrom:handle];
            
            NSString *const channelName = (NSString*) eventPayload[TxTransportKeys_channelName];
            ARTRealtimeChannel *const channel  = [realtime.channels get:channelName];
            listener = [[channel presence] subscribe: ^(ARTPresenceMessage * const message) {
                if(![message isKindOfClass:[ARTPresenceMessage class]]) {
                    emitter([FlutterError errorWithCode:@"AblyFlutterStreamHandler.startListening"
                                message:[NSString stringWithFormat:@"Expected ARTPresenceMessage but received %@", [message class]]
                                details:[NSString stringWithFormat:@"Event %@", eventName]
                    ]);
                } else {
                    emitter(message);
                }
            }];
        } else {
            emitter([FlutterError errorWithCode:@"AblyFlutterStreamHandler.startListening"
                        message:[NSString stringWithFormat:@"Invalid event name: %@", eventName]
                        details:[NSString stringWithFormat:@"Event %@", eventName]
            ]);
        }
    }@catch (NSException *exception) {
        emitter([FlutterError errorWithCode:@"AblyFlutterStreamHandler.startListening"
                    message:exception.reason
                    details:[NSString stringWithFormat:@"Event %@", eventName]
        ]);
    }
}

- (void) cancelListening:(AblyFlutterMessage *const)message {
    AblyFlutterEventMessage *const eventMessage = message.message;
    NSNumber *const handle = message.handle;
    NSString *const eventName = eventMessage.eventName;
    
    if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        [[_instanceStore realtimeFrom:handle].connection off: listener];
    } else if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        // Note: this and all other assert statements in this onCancel method are
        // left as is as there is no way of propagating this error to flutter side
        NSAssert(eventMessage.message, @"event message is missing");
        NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
        ARTRealtime *const realtime = [_instanceStore realtimeFrom:handle];
        
        NSString *const channelName = (NSString*) eventPayload[TxTransportKeys_channelName];
        ARTRealtimeChannel *const channel  = [realtime.channels get:channelName];
        [channel off: listener];
    } else if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        NSAssert(eventMessage.message, @"event message is missing");
        NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
        ARTRealtime *const realtime = [_instanceStore realtimeFrom:handle];
        
        NSString *const channelName = (NSString*) eventPayload[TxTransportKeys_channelName];
        ARTRealtimeChannel *const channel  = [realtime.channels get:channelName];
        [channel unsubscribe: listener];
    } else if ([AblyPlatformMethod_onRealtimePresenceMessage isEqual: eventName]) {
        NSAssert(eventMessage.message, @"event message is missing");
        NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
        ARTRealtime *const realtime = [_instanceStore realtimeFrom:handle];
        
        NSString *const channelName = (NSString*) eventPayload[TxTransportKeys_channelName];
        ARTRealtimeChannel *const channel  = [realtime.channels get:channelName];
        [[channel presence] unsubscribe: listener];
    }
}

@end
