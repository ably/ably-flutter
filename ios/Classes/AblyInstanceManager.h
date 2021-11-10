@import Foundation;
@import Flutter;

@class ARTRest;
@class ARTRealtime;
#import "AblyFlutterClientOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
* Manages [Rest] and [Realtime] client instances by numeric handle. This handle is passed
* to the Dart side to reference a platform side (Android) instance. When the user calls a method
* on a client, the handle is used to get the instance. This allows ablyInstanceManager-flutter to call
* methods on the correct client.
*/
@interface AblyInstanceManager : NSObject

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
