#import "AblyTestFlutterOldskoolPlugin.h"

// TODO work out why importing Ably as a module does not work like this:
//   @import Ably;

#import "Ably.h"

#import "AblyFlutterReaderWriter.h"

#define LOG(fmt, ...) NSLog((@"%@:%d " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterHandler)(AblyTestFlutterOldskoolPlugin * plugin, FlutterMethodCall * call, FlutterResult result);

/**
 Anonymous category providing forward declarations of the methods implemented
 by this class for use within this implementation file, specifically from the
 static FlutterHandle declarations.
 */
@interface AblyTestFlutterOldskoolPlugin ()
-(NSNumber *)addRealtime:(ARTRealtime *)realtime;
-(NSUInteger)disposeOfHandles:(NSArray<NSNumber *> *)handles;
@end

NS_ASSUME_NONNULL_END

static FlutterHandler _getPlatformVersion = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"iOS (UIKit) " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
};

static FlutterHandler _getVersion = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"CocoaPod " stringByAppendingString:[ARTDefault libraryVersion]]);
};

static FlutterHandler _createRealtimeWithOptions = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    ARTClientOptions *const options = call.arguments;
    ARTRealtime *const realtime = [[ARTRealtime alloc] initWithOptions:options];
    result([plugin addRealtime:realtime]);
};

static FlutterHandler _dispose = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result(@([plugin disposeOfHandles:call.arguments]));
};

static NSUInteger _nextId = 1;

@implementation AblyTestFlutterOldskoolPlugin {
    NSDictionary<NSString *, FlutterHandler>* _handlers;
    NSMutableDictionary<NSNumber *, ARTRealtime *>* _realtimeInstances;
    long long _nextHandle;
    NSUInteger _id;
}

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    LOG(@"registrar: %@", [registrar class]);
    FlutterStandardReaderWriter *const readerWriter = [AblyFlutterReaderWriter new];
    FlutterStandardMethodCodec *const methodCodec =
        [FlutterStandardMethodCodec codecWithReaderWriter:readerWriter];
    FlutterMethodChannel *const channel =
        [FlutterMethodChannel methodChannelWithName:@"ably_test_flutter_oldskool_plugin"
                                    binaryMessenger:[registrar messenger]
                                              codec:methodCodec];
    AblyTestFlutterOldskoolPlugin *const plugin = [[AblyTestFlutterOldskoolPlugin alloc] init];
    [registrar addMethodCallDelegate:plugin channel:channel];
}

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _handlers = @{
        @"getPlatformVersion": _getPlatformVersion,
        @"getVersion": _getVersion,
        @"createRealtimeWithOptions": _createRealtimeWithOptions,
        @"dispose": _dispose,
    };
    
    _realtimeInstances = [NSMutableDictionary new];
    _nextHandle = 1;
    _id = _nextId++;
    
    LOG(@"id = %@", @(_id));

    return self;
}

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    LOG(@"%@(%@)", call.method, call.arguments ? [call.arguments class] : @"");
    const FlutterHandler handler = [_handlers objectForKey:call.method];
    if (!handler) {
        // We don't have a handler for a method with this name so tell the caller.
        result(FlutterMethodNotImplemented);
    } else {
        // We have a handler for a method with this name so delegate to it.
        handler(self, call, result);
    }
}

-(NSNumber *)addRealtime:(ARTRealtime *const)realtime {
    NSNumber *const handle = @(_nextHandle++);
    [_realtimeInstances setObject:realtime forKey:handle];
    return handle;
}

-(NSUInteger)disposeOfHandles:(NSArray<NSNumber *> *const)handles {
    const NSUInteger _startCount = _realtimeInstances.count;
    [_realtimeInstances removeObjectsForKeys:handles];
    return _startCount - _realtimeInstances.count;
}

@end
