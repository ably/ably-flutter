#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    UNUserNotificationCenter.currentNotificationCenter.delegate = self;
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// Only called when the app is in the foreground, to check if you want to show the notification to the user.
#pragma mark - Push Notifications - UNUserNotificationCenterDelegate
// https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate?language=objc
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    // You can decide to show/ hide the notification when the app is in the foreground.
    // On Android, notifications are always hidden when the app is in the foreground.
    // To hide foreground notifications on Android, use UNNotificationPresentationOptionNone.
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionBanner);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert);
    }
}

// Only called when `'content-available' : 1` is set in the push payload
# pragma mark - Push Notifications - FlutterApplicationLifeCycleDelegate (UIApplicationDelegate)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // You can handle your message.
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - Push Notifications - UNNotificationContentExtension
// From apple docs: The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    // Handle the user tapping on your notification.
    completionHandler();
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError was called with error: %@", error.localizedDescription);
}

@end
