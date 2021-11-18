import Foundation

class Notification: NSObject {
    @objc
    let title: String?;
    @objc
    let body: String?;
    
    init(title: String?, body: String?) {
      self.title = title
      self.body = body
    }
    
    convenience init?(from userInfo: [AnyHashable : Any]) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                let title = alert["title"] as? String
                let body = alert["body"] as? String
                self.init(title: title, body: body)
            } else if let title = aps["alert"] as? String {
                self.init(title: title, body: nil)
            } else {
                self.init(title: nil, body: nil)
                return nil;
            }
        } else {
            self.init(title: nil, body: nil)
            return nil;
        }
    }
}
