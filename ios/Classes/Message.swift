import Foundation


class Message: NSObject {
    @objc
    public let message: Any
    @objc
    public let handle: Int
    
    @objc
    init(message: Any, handle: Int) {
        self.message = message
        self.handle = handle
    }
}
