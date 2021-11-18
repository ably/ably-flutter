import Foundation

class Notification: NSObject {
    @objc
    var title: String?;
    @objc
    var body: String?;
    
    init(title: String, body: String) {
        self.title = title;
        self.body = body;
    }
    
    override init() {
        self.title = nil;
        self.body = nil;
    }
    
    convenience init?(from userInfo: [AnyHashable : Any]) {
        self.init()
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                title = alert["title"] as? String
                body = alert["body"] as? String
            } else {
                return nil
            }
        }
    }
}
