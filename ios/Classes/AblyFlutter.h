@import Foundation;

@class ARTClientOptions;

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject

-(NSNumber *)createRealtimeWithOptions:(ARTClientOptions *)options;

/**
 This method must be called from the main dispatch queue. It may only be called
 once.
 
 @param completionHandler Will be called on the main dispatch queue when all
 platform objects have been closed down cleanly.
 */
-(void)disposeWithCompletionHandler:(dispatch_block_t)completionHandler;

@end

NS_ASSUME_NONNULL_END
