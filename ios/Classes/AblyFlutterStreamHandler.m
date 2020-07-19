#import "AblyFlutterStreamHandler.h"
#import "AblyFlutterPlugin.h"
#import "AblyFlutterMessage.h"
#import "ARTRealtime.h"
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

    if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        ARTRealtime* realtimeWithHandle = [_ably realtimeWithHandle: handle];
        listener = [realtimeWithHandle.connection  on: ^(ARTConnectionStateChange * const stateChange) {
            emitter(stateChange);
        }];
    } else {
        emitter([FlutterError errorWithCode:@"error" message:[NSString stringWithFormat:@"Invalid event name: %@", eventName] details:nil]);
    }
}

- (void) cancelListening:(AblyFlutterMessage *const)message {
    AblyFlutterEventMessage *const eventMessage = message.message;
    NSNumber *const handle = message.handle;
    NSString *const eventName = eventMessage.eventName;
    
    if([AblyPlatformMethod_onRealtimeConnectionStateChanged isEqual: eventName]) {
        [[_ably realtimeWithHandle: handle].connection  off: listener];
    }
}

@end
