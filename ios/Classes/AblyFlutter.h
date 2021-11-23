@import Foundation;
@import Flutter;

@class ARTRest;
@class ARTRealtime;
#import "AblyFlutterClientOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject

@property (nullable) FlutterMethodChannel * channel;

+ (instancetype)sharedInstance;

-(NSNumber *)setRest:(ARTRest *const)rest with:(int)handle;

-(nullable ARTRest *)getRest:(NSNumber *)handle;

-(NSNumber *)setRealtime:(ARTRealtime *const)realtime with:(int)handle;

-(nullable ARTRealtime *)realtimeWithHandle:(NSNumber *)handle;

-(NSNumber *)setPaginatedResult:(ARTPaginatedResult *const)result handle:(nullable NSNumber *)handle;

-(ARTPaginatedResult *) getPaginatedResult:(NSNumber *const) handle;

-(void)dispose;

@end

NS_ASSUME_NONNULL_END
