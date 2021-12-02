@import Ably;

#import "AblyInstanceStore.h"
#import <ably_flutter/ably_flutter-Swift.h>

@implementation AblyInstanceStore {
    NSMutableDictionary<NSNumber *, ARTRealtime *>* _realtimeInstances;
    NSMutableDictionary<NSNumber *, ARTRest *>* _restInstances;
    NSMutableDictionary<NSNumber *, ARTPaginatedResult *>* _paginatedResults;
    long long _nextHandle;
}

+ (AblyInstanceStore *)sharedInstance {
    static AblyInstanceStore *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(NSNumber *) getNextHandle {
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

-(void)setRest:(ARTRest *const)rest with:(NSNumber *const)handle {
    _restInstances[handle] = rest;
}

-(ARTRest *)restFrom:(NSNumber *)handle {
    return _restInstances[handle];
}

-(void)setRealtime:(ARTRealtime *const)realtime with:(NSNumber *const)handle {
    _realtimeInstances[handle] = realtime;
}

-(ARTRealtime *)realtimeFrom:(NSNumber *)handle {
    return _realtimeInstances[handle];
}

-(NSNumber *)setPaginatedResult:(ARTPaginatedResult *const)result handle:(NSNumber *) handle {
    if(!handle){
        handle = @(_nextHandle++);
    }
    _paginatedResults[handle] = result;
    return handle;
}

-(ARTPaginatedResult *) getPaginatedResult:(NSNumber *const) handle {
    return _paginatedResults[handle];
}

-(void)reset {
    for (ARTRealtime *const r in _realtimeInstances.allValues) {
        [r close];
    }
    [_realtimeInstances removeAllObjects];
    [_restInstances removeAllObjects];
}

@end

