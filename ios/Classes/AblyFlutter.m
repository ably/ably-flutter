@import Ably;

#import "AblyFlutter.h"
#import "AblyFlutterMessage.h"
#import "AblyFlutterClientOptions.h"
#import "codec/AblyPlatformConstants.h"


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

-(NSNumber *)createRestWithOptions:(AblyFlutterClientOptions *const)options {
    if (!options) {
        [NSException raise:NSInvalidArgumentException format:@"options cannot be nil."];
    }
    NSNumber *const handle = @(_nextHandle++);
    if(options.hasAuthCallback){
        options.clientOptions.authCallback =
        ^(ARTTokenParams *tokenParams, void(^callback)(id<ARTTokenDetailsCompatible>, NSError *)){
            AblyFlutterMessage *const message
            = [[AblyFlutterMessage alloc] initWithMessage:tokenParams handle: handle];
            [self->_channel invokeMethod:AblyPlatformMethod_authCallback
                               arguments:message
                                  result:^(id tokenData){
                if (!tokenData) {
                    NSLog(@"No token data recieved %@", tokenData);
                    callback(nil, [NSError errorWithDomain:ARTAblyErrorDomain
                                                      code:ARTCodeErrorAuthConfiguredProviderFailure
                                                  userInfo:nil]); //TODO check if this is okay!
                } if ([tokenData isKindOfClass:[FlutterError class]]) {
                    NSLog(@"Error getting token data %@", tokenData);
                    callback(nil, tokenData);
                } else {
                    callback(tokenData, nil);
                }
            }];
        };
    }
    ARTRest *const instance = [[ARTRest alloc] initWithOptions:options.clientOptions];
    [_restInstances setObject:instance forKey:handle];
    return handle;
}

-(ARTRest *)getRest:(NSNumber *const)handle {
    return [_restInstances objectForKey:handle];
}

-(NSNumber *)createRealtimeWithOptions:(AblyFlutterClientOptions *const)options {
    if (!options) {
        [NSException raise:NSInvalidArgumentException format:@"options cannot be nil."];
    }
    
    ARTRealtime *const instance = [[ARTRealtime alloc] initWithOptions:options.clientOptions];
    NSNumber *const handle = @(_nextHandle++);
    if(options.hasAuthCallback){
        options.clientOptions.authCallback =
        ^(ARTTokenParams *tokenParams, void(^callback)(id<ARTTokenDetailsCompatible>, NSError *)){
            AblyFlutterMessage *const message
            = [[AblyFlutterMessage alloc] initWithMessage:tokenParams handle: handle];
            [self->_channel invokeMethod:AblyPlatformMethod_realtimeAuthCallback
                               arguments:message
                                  result:^(id tokenData){
                if (!tokenData) {
                    NSLog(@"No token data received %@", tokenData);
                    callback(nil, [NSError errorWithDomain:ARTAblyErrorDomain
                                                      code:ARTCodeErrorAuthConfiguredProviderFailure
                                                  userInfo:nil]); //TODO check if this is okay!
                } if ([tokenData isKindOfClass:[FlutterError class]]) {
                    NSLog(@"Error getting token data %@", tokenData);
                    callback(nil, tokenData);
                } else {
                    callback(tokenData, nil);
                }
            }];
        };
    }
    ARTRealtime *const instance = [[ARTRealtime alloc] initWithOptions:options.clientOptions];
    [_realtimeInstances setObject:instance forKey:handle];
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
    
    // TODO upgrade iOS runtime requirement to 10.0 so we can use this:
    // dispatch_assert_queue(dispatch_get_main_queue());
    
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
