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
        let message = RemoteMessage.fromNotificationContent(content:notification.request.content);
        methodChannel.invokeMethod(AblyPlatformMethod_pushOnShowNotificationInForeground, arguments: message) { result in
            if let result = result as? NSNumber, result == NSNumber(value: true) {
                if #available(iOS 14.0, *) {
                    completionHandler(.banner)
                } else {
                    completionHandler(.alert)
                }
            } else {
                completionHandler([])
            }
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let remoteMessage = RemoteMessage.fromNotificationContent(content: response.notification.request.content)
        methodChannel.invokeMethod(AblyPlatformMethod_pushOnNotificationTap, arguments: remoteMessage, result: nil)
        
        if let delegate = delegate {
            // TODO Call dart side to say error, we did not call this because the delegate was already set.
            delegate.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        } else {
            // TODO give the response to the user
            completionHandler()
        }
    }
    
    // Do nothing, but pass the arguments to the original delegate.
    @available(iOS 12.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        if let delegate = delegate {
            delegate.userNotificationCenter?(center, openSettingsFor: notification)
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
