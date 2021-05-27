@import Ably.ARTRealtime;

#import "AblyFlutterStreamHandler.h"
#import "AblyFlutterPlugin.h"
#import "AblyFlutterMessage.h"
#import "codec/AblyPlatformConstants.h"

@implementation AblyFlutterStreamHandler{
    ARTEventListener *listener;
}

@synthesize ably = _ably;

- (instancetype)init{
    _ably = [AblyFlutter sharedInstance];
    listener = [ARTEventListener new];
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

- (void) startListening:(AblyFlutterMessage *const)message emitter:(FlutterEventSink)emitter {
    AblyFlutterEventMessage *const eventMessage = message.message;
    NSNumber *const handle = message.handle;
    NSString *const eventName = eventMessage.eventName;
    @try {
        if ([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
            ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
            listener = [realtimeWithHandle.connection  on: ^(ARTConnectionStateChange * const stateChange) {
                emitter(stateChange);
            }];
        } else if ([AblyPlatformMethod_onRealtimeChannelStateChanged isEqual: eventName]) {
            NSAssert(eventMessage.message, @"event message is missing");
            NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
            ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
            
            NSString *channelName = (NSString*)[eventPayload objectForKey:TxTransportKeys_channelName];
            ARTRealtimeChannel *channel = [realtimeWithHandle.channels get:channelName];
            
            listener = [channel on: ^(ARTChannelStateChange * const stateChange) {
                emitter(stateChange);
            }];
        } else if ([AblyPlatformMethod_onRealtimeChannelMessage isEqual: eventName]) {
            NSAssert(eventMessage.message, @"event message is missing");
            NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
            ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
            
            NSString *channelName = (NSString*)[eventPayload objectForKey:TxTransportKeys_channelName];
            ARTRealtimeChannel *channel = [realtimeWithHandle.channels get:channelName];
            
            listener = [channel subscribe: ^(ARTMessage * const message) {
                emitter(message);
            }];
        } else if ([AblyPlatformMethod_onRealtimePresenceMessage isEqual: eventName]) {
            NSAssert(eventMessage.message, @"event message is missing");
            NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
            ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
            
            NSString *channelName = (NSString*)[eventPayload objectForKey:TxTransportKeys_channelName];
            ARTRealtimeChannel *channel = [realtimeWithHandle.channels get:channelName];
            listener = [[channel presence] subscribe: ^(ARTPresenceMessage * const message) {
                emitter(message);
            }];
        } else {
            emitter([FlutterError errorWithCode:@"error" message:[NSString stringWithFormat:@"Invalid event name: %@", eventName] details:nil]);
        }
    }@catch (NSException *exception) {
        emitter([FlutterError errorWithCode:@"error" message:exception.reason details:eventName]);
    }
}

- (void) cancelListening:(AblyFlutterMessage *const)message {
    AblyFlutterEventMessage *const eventMessage = message.message;
    NSNumber *const handle = message.handle;
    NSString *const eventName = eventMessage.eventName;
    
    if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        [[_ably realtimeWithHandle: handle].connection  off: listener];
    } else if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        // Note: this and all other assert statements in this onCancel method are
        // left as is as there is no way of propagating this error to flutter side
        NSAssert(eventMessage.message, @"event message is missing");
        NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
        ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
        
        NSString *channelName = (NSString*)[eventPayload objectForKey:TxTransportKeys_channelName];
        ARTRealtimeChannel *channel = [realtimeWithHandle.channels get:channelName];
        [channel off: listener];
    } else if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        NSAssert(eventMessage.message, @"event message is missing");
        NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
        ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
        
        NSString *channelName = (NSString*)[eventPayload objectForKey:TxTransportKeys_channelName];
        ARTRealtimeChannel *channel = [realtimeWithHandle.channels get:channelName];
        [channel unsubscribe: listener];
    } else if ([AblyPlatformMethod_onRealtimePresenceMessage isEqual: eventName]) {
        NSAssert(eventMessage.message, @"event message is missing");
        NSMutableDictionary<NSString *, NSObject *>* eventPayload = eventMessage.message;
        ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
        
        NSString *channelName = (NSString*)[eventPayload objectForKey:TxTransportKeys_channelName];
        ARTRealtimeChannel *channel = [realtimeWithHandle.channels get:channelName];
        [[channel presence] unsubscribe: listener];
    }
}

@end
