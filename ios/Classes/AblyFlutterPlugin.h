#import <Flutter/Flutter.h>
#import "AblyInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterPlugin : NSObject<FlutterPlugin, UNUserNotificationCenterDelegate>

+(instancetype)new NS_UNAVAILABLE;
+(instancetype)init NS_UNAVAILABLE;

@property(nonatomic) AblyInstanceManager * ablyInstanceManager;
@property(nonatomic, nullable) NSData * didRegisterForRemoteNotificationsWithDeviceToken_deviceToken;
@property(nonatomic, nullable) NSError * didFailToRegisterForRemoteNotificationsWithError_error;

@end

NS_ASSUME_NONNULL_END
