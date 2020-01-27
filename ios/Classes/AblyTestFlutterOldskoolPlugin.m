#import "AblyTestFlutterOldskoolPlugin.h"

// TODO work out why importing Ably as a module does not work like this:
//   @import Ably;

#import "Ably.h"

#import "AblyFlutterReaderWriter.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterHandler)(AblyTestFlutterOldskoolPlugin * plugin, FlutterMethodCall * call, FlutterResult result);

NS_ASSUME_NONNULL_END

static FlutterHandler _getPlatformVersion = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"iOS (UIKit) " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
};

static FlutterHandler _getVersion = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"CocoaPod " stringByAppendingString:[ARTDefault libraryVersion]]);
};

@implementation AblyTestFlutterOldskoolPlugin {
    NSDictionary<NSString *, FlutterHandler>* _handlers;
}

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
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
    };

    return self;
}

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    const FlutterHandler handler = [_handlers objectForKey:call.method];
    if (!handler) {
        // We don't have a handler for a method with this name so tell the caller.
        result(FlutterMethodNotImplemented);
    } else {
        // We have a handler for a method with this name so delegate to it.
        handler(self, call, result);
    }
}

@end
