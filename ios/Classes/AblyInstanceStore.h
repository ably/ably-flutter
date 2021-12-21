@import Foundation;
@import Flutter;

@class ARTRest;
@class ARTRealtime;
#import "AblyFlutterClientOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyInstanceStore : NSObject

+ (instancetype)sharedInstance;

-(NSNumber *) getNextHandle;

-(void)setRest:(ARTRest *const)rest with:(NSNumber *const)handle;

-(nullable ARTRest *)restFrom:(NSNumber *)handle;

-(void)setRealtime:(ARTRealtime *const)realtime with:(NSNumber *const)handle;

-(nullable ARTRealtime *)realtimeFrom:(NSNumber *)handle;

-(NSNumber *)setPaginatedResult:(ARTPaginatedResult *const)result handle:(nullable NSNumber *)handle;

-(ARTPaginatedResult *) getPaginatedResult:(NSNumber *const) handle;

-(void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *const) deviceToken;

@property(nonatomic, nullable) NSData * didRegisterForRemoteNotificationsWithDeviceToken_deviceToken;

@property(nonatomic, nullable) NSError * didFailToRegisterForRemoteNotificationsWithError_error;

-(void)reset;

@end

NS_ASSUME_NONNULL_END

