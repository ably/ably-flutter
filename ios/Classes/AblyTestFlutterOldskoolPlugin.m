#import "AblyTestFlutterOldskoolPlugin.h"

// TODO work out why importing Ably as a module does not work like this:
//   @import Ably;
#import "Ably.h"

#import "AblyFlutterReaderWriter.h"
#import "AblyFlutterMessage.h"
#import "AblyFlutter.h"

#define LOG(fmt, ...) NSLog((@"%@:%d " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

typedef void (^FlutterHandler)(AblyTestFlutterOldskoolPlugin * plugin, FlutterMethodCall * call, FlutterResult result);

/**
 Anonymous category providing forward declarations of the methods implemented
 by this class for use within this implementation file, specifically from the
 static FlutterHandle declarations.
 */
@interface AblyTestFlutterOldskoolPlugin ()
-(void)registerWithCompletionHandler:(FlutterResult)completionHandler;
-(nullable AblyFlutter *)ablyWithHandle:(NSNumber *)handle;
@end

NS_ASSUME_NONNULL_END

static FlutterHandler _getPlatformVersion = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"iOS (UIKit) " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
};

static FlutterHandler _getVersion = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    result([@"CocoaPod " stringByAppendingString:[ARTDefault libraryVersion]]);
};

static FlutterHandler _register = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    [plugin registerWithCompletionHandler:result];
};

static FlutterHandler _createRealtimeWithOptions = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    AblyFlutterMessage *const message = call.arguments;
    LOG(@"message for handle %@", message.handle);
    AblyFlutter *const ably = [plugin ablyWithHandle:message.handle];
    // TODO if ably is nil here then an error response, perhaps? or allow Dart side to understand null response?
    result([ably createRealtimeWithOptions:message.message]);
};

static FlutterHandler _dispose = ^void(AblyTestFlutterOldskoolPlugin *const plugin, FlutterMethodCall *const call, const FlutterResult result) {
    // TODO
};

@implementation AblyTestFlutterOldskoolPlugin {
    long long _nextRegistration;
    NSDictionary<NSString *, FlutterHandler>* _handlers;
    NSNumber* _ablyHandle;
    AblyFlutter* _ably;
    FlutterMethodChannel* _channel;
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
    AblyTestFlutterOldskoolPlugin *const plugin = [[AblyTestFlutterOldskoolPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:plugin channel:channel];
}

-(instancetype)initWithChannel:(FlutterMethodChannel *const)channel {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _handlers = @{
        @"getPlatformVersion": _getPlatformVersion,
        @"getVersion": _getVersion,
        @"register": _register,
        @"createRealtimeWithOptions": _createRealtimeWithOptions,
        @"dispose": _dispose,
    };
    
    _nextRegistration = 1;
    _channel = channel;
    
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

-(void)registerWithCompletionHandler:(const FlutterResult)completionHandler {
    if (!completionHandler) {
        [NSException raise:NSInvalidArgumentException
                    format:@"completionHandler cannot be nil."];
    }
    
    if (_ably && !_ablyHandle) {
        // TODO could this ever happen and, in which case, do we need to cater for it?
        [NSException raise:NSInternalInconsistencyException
                    format:@"Registration request received when still not finished processing last request."];
    }
    
    // TODO upgrade iOS runtime requirement to 10.0 so we can use this:
    // dispatch_assert_queue(dispatch_get_main_queue());
    
    NSNumber *const handle = @(_nextRegistration++);
    LOG(@"NEW AblyFlutter with handle %@", handle);

    if (_ablyHandle) {
        LOG(@"Disposing of previous Ably instance (# %@).", _ablyHandle);
    }

    // Setting _ablyHandle to nil when _ably is not nil indicates that we're
    // in the process of asynchronously disposing of the old instance.
    _ablyHandle = nil;
    
    const dispatch_block_t createNew = ^
    {
        LOG(@"Creating new Ably instance (# %@).", handle);
        self->_ably = [AblyFlutter new];
        self->_ablyHandle = handle;
        completionHandler(handle);
    };
    
    if (_ably) {
        [_ably disposeWithCompletionHandler:^
        {
            createNew();
        }];
    } else {
        createNew();
    }
}

-(AblyFlutter *)ablyWithHandle:(NSNumber *)handle {
    if (![handle isEqualToNumber:_ablyHandle]) {
        return nil;
    }
    return _ably;
}

@end
