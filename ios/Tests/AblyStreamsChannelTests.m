#import <XCTest/XCTest.h>
#import <Flutter/Flutter.h>
#import "AblyStreamsChannel.h"

// Mock binary messenger: captures the binaryMessageHandler registered by AblyStreamsChannel,
// and optionally throws NSInternalInconsistencyException on sendOnChannel:message: to simulate
// a suspended/detached FlutterEngine.
@interface MockThrowingMessenger : NSObject <FlutterBinaryMessenger>
@property(nonatomic, copy) FlutterBinaryMessageHandler capturedHandler;
@property(nonatomic, assign) BOOL shouldThrow;
@property(nonatomic, assign) NSInteger sendCallCount;
@end

@implementation MockThrowingMessenger

- (void)sendOnChannel:(NSString*)channel message:(NSData*)message {
    _sendCallCount++;
    if (_shouldThrow) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Sending a message before the FlutterEngine has been run."];
    }
}

- (void)sendOnChannel:(NSString*)channel message:(NSData*)message binaryReply:(FlutterBinaryReply)callback {}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(NSString*)channel
                                          binaryMessageHandler:(FlutterBinaryMessageHandler _Nullable)handler {
    _capturedHandler = handler;
    return 0;
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(NSString*)channel
                                          binaryMessageHandler:(FlutterBinaryMessageHandler _Nullable)handler
                                                     taskQueue:(NSObject<FlutterTaskQueue>* _Nullable)taskQueue {
    _capturedHandler = handler;
    return 0;
}

- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {}

- (NSObject<FlutterTaskQueue>*)makeBackgroundTaskQueue { return nil; }

@end

// Helper stream handler that captures the eventSink passed to it during stream setup.
@interface CapturingSinkHandler : NSObject <FlutterStreamHandler>
@property(nonatomic, copy) FlutterEventSink capturedSink;
@end

@implementation CapturingSinkHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    _capturedSink = events;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments { return nil; }

@end

@interface AblyStreamsChannelTests : XCTestCase
@end

@implementation AblyStreamsChannelTests

// Sets up an AblyStreamsChannel with the given messenger and triggers a "listen#1" call,
// which causes the channel to create a sink and pass it to the handler's onListenWithArguments:.
// Returns the handler so tests can invoke the captured sink.
- (CapturingSinkHandler*)setupChannelWithMessenger:(MockThrowingMessenger*)messenger {
    AblyStreamsChannel *channel = [AblyStreamsChannel
        streamsChannelWithName:@"test.channel"
               binaryMessenger:messenger
                         codec:[FlutterStandardMethodCodec sharedInstance]];

    CapturingSinkHandler *handler = [CapturingSinkHandler new];
    [channel setStreamHandlerFactory:^NSObject<FlutterStreamHandler>*(id args) { return handler; }];

    // Simulate Flutter sending a "listen#1" message to open a stream.
    // Arguments must be non-nil: AblyStreamsChannel stores them in an NSMutableDictionary
    // which rejects nil values.
    NSData *listenMsg = [[FlutterStandardMethodCodec sharedInstance]
        encodeMethodCall:[FlutterMethodCall methodCallWithMethodName:@"listen#1" arguments:@{}]];
    messenger.capturedHandler(listenMsg, ^(NSData* reply){});

    return handler;
}

// Regression test for: NSInternalInconsistencyException crash when the FlutterEngine is
// suspended after the app is backgrounded.
// The sink block in AblyStreamsChannel must catch the exception instead of propagating it.
- (void)testSinkDoesNotCrashWhenEngineNotRunning {
    MockThrowingMessenger *messenger = [MockThrowingMessenger new];
    messenger.shouldThrow = YES;
    CapturingSinkHandler *handler = [self setupChannelWithMessenger:messenger];

    XCTAssertNoThrow(handler.capturedSink(@"state-change-event"),
        @"Sink should swallow NSInternalInconsistencyException when engine is stopped");
}

// Verify the normal (foreground) code path still works after the fix.
- (void)testSinkEmitsNormallyWhenEngineIsRunning {
    MockThrowingMessenger *messenger = [MockThrowingMessenger new];
    messenger.shouldThrow = NO;
    CapturingSinkHandler *handler = [self setupChannelWithMessenger:messenger];

    XCTAssertNoThrow(handler.capturedSink(@"state-change-event"));
    XCTAssertEqual(messenger.sendCallCount, 1,
        @"Messenger should be called once for a normal event emission");
}

@end
