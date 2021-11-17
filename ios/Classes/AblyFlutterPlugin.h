#import <Flutter/Flutter.h>
#import "AblyFlutter.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutterPlugin : NSObject<FlutterPlugin, UNUserNotificationCenterDelegate>

+(instancetype)new NS_UNAVAILABLE;
+(instancetype)init NS_UNAVAILABLE;

@property(nonatomic) AblyFlutter * ably;
@property(nonatomic, nullable) NSData * didRegisterForRemoteNotificationsWithDeviceToken_deviceToken;
@property(nonatomic, nullable) NSError * didFailToRegisterForRemoteNotificationsWithError_error;

@end

NS_ASSUME_NONNULL_END
