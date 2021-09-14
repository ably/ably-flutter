#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Warning: Do not set UNUserNotificationCenter.currentNotificationCenter.delegate
    // AFTER GeneratedPluginRegistrant:registerWithRegistry: is called (when Ably Flutter
    // initializes), as this would break functionality. Instead, set it before plugin
    // registration:
    //UNUserNotificationCenter.currentNotificationCenter.delegate = self;
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError was called with error: %@", error.localizedDescription);
}

@end
