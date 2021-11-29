import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("application:didFailToRegisterForRemoteNotificationsWithError was called with error: %@", error.localizedDescription)
    }
}
