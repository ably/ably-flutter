@import Foundation;
@import Flutter;

@class ARTRest;
@class ARTRealtime;
#import "AblyFlutterClientOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject

@property (nullable) FlutterMethodChannel * channel;

+ (instancetype)sharedInstance;

-(NSNumber *)createRestWithOptions:(AblyFlutterClientOptions *)options;

-(nullable ARTRest *)getRest:(NSNumber *)handle;

-(NSNumber *)createRealtimeWithOptions:(AblyFlutterClientOptions *)options;

-(nullable ARTRealtime *)realtimeWithHandle:(NSNumber *)handle;

-(NSNumber *)setPaginatedResult:(ARTPaginatedResult *const)result handle:(nullable NSNumber *)handle;

-(ARTPaginatedResult *) getPaginatedResult:(NSNumber *const) handle;

/**
 This method must be called from the main dispatch queue. It may only be called
 once.
 
 @param completionHandler Will be called on the main dispatch queue when all
 platform objects have been closed down cleanly.
 */
-(void)disposeWithCompletionHandler:(dispatch_block_t)completionHandler;

@end

NS_ASSUME_NONNULL_END
