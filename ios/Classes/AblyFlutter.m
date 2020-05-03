#import "AblyFlutter.h"

// TODO work out why importing Ably as a module does not work like this:
//   @import Ably;
#import "Ably.h"


@implementation AblyFlutter {
    BOOL _disposed;
    NSMutableDictionary<NSNumber *, ARTRealtime *>* _realtimeInstances;
    NSMutableDictionary<NSNumber *, ARTRest *>* _restInstances;
    long long _nextHandle;
}

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _realtimeInstances = [NSMutableDictionary new];
    _restInstances = [NSMutableDictionary new];
    _nextHandle = 1;

    return self;
}

#define ASSERT_NOT_DISPOSED \
    if (_disposed) { \
        [NSException raise:NSInternalInconsistencyException \
                    format:@"Instance disposed."]; \
    }

-(NSNumber *)createRestWithOptions:(ARTClientOptions *const)options {
    if (!options) {
        [NSException raise:NSInvalidArgumentException format:@"options cannot be nil."];
    }
    
    ASSERT_NOT_DISPOSED
    
    ARTRest *const instance = [[ARTRest alloc] initWithOptions:options];
    NSNumber *const handle = @(_nextHandle++);
    [_restInstances setObject:instance forKey:handle];
    return handle;
}

-(ARTRest *)getRest:(NSNumber *const)handle {
    return [_restInstances objectForKey:handle];
}

-(NSNumber *)createRealtimeWithOptions:(ARTClientOptions *const)options {
    if (!options) {
        [NSException raise:NSInvalidArgumentException format:@"options cannot be nil."];
    }
    
    ASSERT_NOT_DISPOSED
    
    ARTRealtime *const instance = [[ARTRealtime alloc] initWithOptions:options];
    NSNumber *const handle = @(_nextHandle++);
    [_realtimeInstances setObject:instance forKey:handle];
    return handle;
}

-(ARTRealtime *)realtimeWithHandle:(NSNumber *const)handle {
    return [_realtimeInstances objectForKey:handle];
}

-(void)disposeWithCompletionHandler:(const dispatch_block_t)completionHandler {
    if (!completionHandler) {
        [NSException raise:NSInvalidArgumentException format:@"completionHandler cannot be nil."];
    }

    ASSERT_NOT_DISPOSED

    // TODO upgrade iOS runtime requirement to 10.0 so we can use this:
    // dispatch_assert_queue(dispatch_get_main_queue());
    
    // This is contrived for now but the point is that we can introduce a clean,
    // asynchronous close via a background queue here if required.
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self dispose];
        completionHandler();
    });
}

-(void)dispose {
    for (ARTRealtime *const r in _realtimeInstances.allValues) {
        [r close];
    }
    [_realtimeInstances removeAllObjects];
}

@end
