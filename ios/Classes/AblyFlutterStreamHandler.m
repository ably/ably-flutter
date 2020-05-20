#import "AblyFlutterStreamHandler.h"
#import "AblyFlutterPlugin.h"
#import "AblyFlutterMessage.h"
#import "ARTRealtime.h"
#import "codec/AblyPlatformConstants.h"

@implementation AblyFlutterStreamHandler{
    ARTEventListener *listener;
}

@synthesize plugin = _plugin;

- (instancetype)initWithAbly:(AblyFlutterPlugin *const)plugin {
    _plugin = plugin;
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
    AblyFlutter *const ably = [_plugin ablyWithHandle: message.handle];
    AblyFlutterMessage *const _message = message.message;
    NSString *const eventName = _message.message;

    if([AblyPlatformMethod.onRealtimeConnectionStateChanged isEqual: eventName]) {
        listener = [[ably realtimeWithHandle: message.handle].connection  on: ^(ARTConnectionStateChange * const stateChange) {
            emitter(stateChange);
        }];
    } else if([AblyPlatformMethod.onRealtimeChannelStateChanged isEqual: eventName]) {
        
    }
}

- (void) cancelListening:(AblyFlutterMessage *const)message {
    AblyFlutter *const ably = [_plugin ablyWithHandle: message.handle];
    AblyFlutterMessage *const _message = message.message;
    NSString *const eventName = _message.message;
    
    if([AblyPlatformMethod.onRealtimeConnectionStateChanged isEqual: eventName]) {
        [[ably realtimeWithHandle: message.handle].connection  off: listener];
    } else if([AblyPlatformMethod.onRealtimeChannelStateChanged isEqual: eventName]) {
            
    }
}

@end
