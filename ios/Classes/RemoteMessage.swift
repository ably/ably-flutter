import Foundation
import UIKit

public class RemoteMessage: NSObject {
    @objc
    let data: NSDictionary?;
    @objc
    let notification: Notification?;
    
    init(data: NSDictionary?, notification: Notification?) {
        self.data = data;
        self.notification = notification;
    }
    
    static func fromNotificationContent(content: UNNotificationContent) -> RemoteMessage {
        let userInfo = content.userInfo;
        let title = content.title;
        let body = content.body;
        let notification = Notification(title: title, body: body);
        return RemoteMessage(data: userInfo._bridgeToObjectiveC(), notification: notification);
    }
}

class Notification: NSObject {
    @objc
    let title: String?;
    @objc
    let body: String?;
    
    init(title: String, body: String) {
        self.title = title;
        self.body = body;
    }
}
