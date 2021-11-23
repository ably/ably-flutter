@import Foundation;
@import Flutter;

@class ARTRest;
@class ARTRealtime;
#import "AblyFlutterClientOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject

+ (instancetype)sharedInstance;

-(NSNumber *) getNextHandle;

-(void)setRest:(ARTRest *const)rest with:(NSNumber *const)handle;

-(nullable ARTRest *)getRest:(NSNumber *)handle;

-(void)setRealtime:(ARTRealtime *const)realtime with:(NSNumber *const)handle;

-(nullable ARTRealtime *)realtimeWithHandle:(NSNumber *)handle;

-(NSNumber *)setPaginatedResult:(ARTPaginatedResult *const)result handle:(nullable NSNumber *)handle;

-(ARTPaginatedResult *) getPaginatedResult:(NSNumber *const) handle;

-(void)reset;

@end

NS_ASSUME_NONNULL_END
