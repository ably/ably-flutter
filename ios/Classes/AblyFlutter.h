@import Foundation;

@class ARTRest;
@class ARTRealtime;
@class ARTClientOptions;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject

+ (instancetype)sharedInstance;

-(NSNumber *)createRestWithOptions:(ARTClientOptions *)options;

-(nullable ARTRest *)getRest:(NSNumber *)handle;

-(NSNumber *)createRealtimeWithOptions:(ARTClientOptions *)options;

-(nullable ARTRealtime *)realtimeWithHandle:(NSNumber *)handle;

/**
 This method must be called from the main dispatch queue. It may only be called
 once.
 
 @param completionHandler Will be called on the main dispatch queue when all
 platform objects have been closed down cleanly.
 */
-(void)disposeWithCompletionHandler:(dispatch_block_t)completionHandler;

@end

NS_ASSUME_NONNULL_END
