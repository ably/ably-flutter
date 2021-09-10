import Foundation
import Flutter

// This class implements UNUserNotificationCenterDelegate but makes sure to also call the users
// original UNUserNotificationCenterDelegate methods implemented on the user's delegate set on
// UNUserNotificationCenter.delegate
public class PushNotificationEventHandlers: NSObject, UNUserNotificationCenterDelegate {
    var delegate: UNUserNotificationCenterDelegate? = nil;
    let methodChannel: FlutterMethodChannel
    
    @objc(initWithDelegate:andMethodChannel:) public init(_ delegate: UNUserNotificationCenterDelegate, _ methodChannel: FlutterMethodChannel) {
        self.delegate = delegate;
        self.methodChannel = methodChannel;
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let delegate = delegate {
            // TODO Call dart side to say error, we did not call this because the delegate was already set.
            delegate.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
        } else {
            // TODO give message to dart side to ask user whether to show or not.
            if #available(iOS 14.0, *) {
                completionHandler(.banner)
            } else {
                completionHandler(.alert)
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let delegate = delegate {
            // TODO Call dart side to say error, we did not call this because the delegate was already set.
            delegate.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        } else {
            // TODO give the response to the user
            completionHandler()
        }
    }
    
    @objc
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // TODO check if foreground, background or inactive? See https://developer.apple.com/documentation/uikit/uiapplicationstate?language=objc
        // TODO call dart with userInfo, and run processing, including background processing.
        // It should return an enum, such as `newData`, `NoData`, `failed`, or nil
        if (application.applicationState == .background) {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnBackgroundMessage, arguments: userInfo) { flutterResult in
                if let result = flutterResult as? UIBackgroundFetchResult {
                    completionHandler(result);
                } else {
                    completionHandler(.noData);
                }
            }
        } else {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnMessage, arguments: userInfo) { flutterResult in
                if let result = flutterResult as? UIBackgroundFetchResult {
                    completionHandler(result);
                } else {
                    completionHandler(.noData);
                }
            }
        }
    }
}
