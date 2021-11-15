import Foundation
import Flutter

// This class is used to replace the UNUserNotificationCenterDelegate set by the user.
//
// It makes sure to also call the same delegate methods implemented on the original
// UNUserNotificationCenter.delegate, if it exists
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
        
        // `as` is used because userNotificationCenter on its own is ambiguous (userNotificationCenter corresponds to 3 methods).
        // See https://stackoverflow.com/questions/35658334/how-do-i-resolve-ambiguous-use-of-compile-error-with-swift-selector-syntax
        let didReceiveDelegateMethodSelector = #selector(userNotificationCenter as (UNUserNotificationCenter, UNNotificationResponse, @escaping () -> Void) -> Void)
        if let delegate = delegate, delegate.responds(to: didReceiveDelegateMethodSelector) {
            // Allow users AppDelegate gets a chance to respond.
            delegate.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
        } else {
            completionHandler()
        }
    }
    
    @available(iOS 12.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        methodChannel.invokeMethod(AblyPlatformMethod_pushOpenSettingsFor, arguments: nil, result: nil)
        let openSettingsForDelegateMethodSelector = #selector(userNotificationCenter as (UNUserNotificationCenter, UNNotification?) -> Void)
        if let delegate = delegate, delegate.responds(to: openSettingsForDelegateMethodSelector) {
            delegate.userNotificationCenter?(center, openSettingsFor: notification)
        }
    }
    
    @objc
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        var methodName = AblyPlatformMethod_pushOnMessage;
        if (application.applicationState == .background || application.applicationState == .inactive) {
            methodName = AblyPlatformMethod_pushOnBackgroundMessage
        }
        
        let notification: Notification? = createNotification(from: userInfo);
        let remoteMessage = RemoteMessage(data: userInfo._bridgeToObjectiveC(), notification: notification);
        methodChannel.invokeMethod(methodName, arguments: remoteMessage) { flutterResult in
            completionHandler(.newData);
        }
    }
    
    private func createNotification(from userInfo: [AnyHashable : Any]) -> Notification? {
        let notification = Notification();
        
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let title = alert["title"] as? String {
                    notification.title = title
                }
                if let body = alert["body"] as? String {
                    notification.body = body
                }
            }
        }
        
        if (notification.title != nil || notification.body == nil) {
            // Return an instance of notification only if it has some data.
            return notification;
        }
        
        return nil;
    }
}
