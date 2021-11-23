@import Ably;

#import "AblyFlutter.h"
#import "AblyFlutterMessage.h"
#import "AblyFlutterClientOptions.h"
#import "codec/AblyPlatformConstants.h"
#import <ably_flutter/ably_flutter-Swift.h>


@implementation AblyFlutter {
    FlutterMethodChannel* _channel;
    NSMutableDictionary<NSNumber *, ARTRealtime *>* _realtimeInstances;
    NSMutableDictionary<NSNumber *, ARTRest *>* _restInstances;
    NSMutableDictionary<NSNumber *, ARTPaginatedResult *>* _paginatedResults;
    long long _nextHandle;
}

+ (instancetype)sharedInstance {
    static AblyFlutter *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

-(void) setChannel:(FlutterMethodChannel *const)channel  {
    _channel = channel;
}

-(void) getNextHandle {
    return @(_nextHandle++);
}

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _realtimeInstances = [NSMutableDictionary new];
    _restInstances = [NSMutableDictionary new];
    _paginatedResults = [NSMutableDictionary new];
    _nextHandle = 1;
    
    return self;
}

-(NSNumber *)setRest:(ARTRest *const)rest with:(int)handle {
    [_restInstances setObject:rest forKey:handle];
    return handle;
}

-(ARTRest *)getRest:(NSNumber *const)handle {
    return [_restInstances objectForKey:handle];
}

-(NSNumber *)setRealtime:(ARTRealtime *const)realtime with(int)handle {
    [_realtimeInstances setObject:realtime forKey:handle];
    return handle;
}

-(ARTRealtime *)realtimeWithHandle:(NSNumber *const)handle {
    return [_realtimeInstances objectForKey:handle];
}

-(NSNumber *)setPaginatedResult:(ARTPaginatedResult *const)result handle:(NSNumber *) handle {
    if(!handle){
        handle = @(_nextHandle++);
    }
    [_paginatedResults setObject:result forKey:handle];
    return handle;
}

-(ARTPaginatedResult *) getPaginatedResult:(NSNumber *const) handle {
    return [_paginatedResults objectForKey:handle];
}

-(void)disposeWithCompletionHandler:(const dispatch_block_t)completionHandler {
    if (!completionHandler) {
        [NSException raise:NSInvalidArgumentException format:@"completionHandler cannot be nil."];
    }
    
    dispatch_assert_queue(dispatch_get_main_queue());

    // This is contrived for now but the point is that we can introduce a clean,
    // asynchronous close via a background queue here if required.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dispose];
        completionHandler();
    });
}

-(void)dispose {
    for (ARTRealtime *const r in _realtimeInstances.allValues) {
        [r close];
    }
    [_realtimeInstances removeAllObjects];
    [_restInstances removeAllObjects];
}

@end
