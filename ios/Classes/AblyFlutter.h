#import <Flutter/Flutter.h>
#import "AblyInstanceStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface AblyFlutter : NSObject<FlutterPlugin, UNUserNotificationCenterDelegate>

+(instancetype)new NS_UNAVAILABLE;
+(instancetype)init NS_UNAVAILABLE;

@property(nonatomic) AblyInstanceStore * instanceStore;
@property(nonatomic) FlutterMethodChannel *channel;
@property(nonatomic, nullable) NSData * didRegisterForRemoteNotificationsWithDeviceToken_deviceToken;
@property(nonatomic, nullable) NSError * didFailToRegisterForRemoteNotificationsWithError_error;

@end

NS_ASSUME_NONNULL_END
