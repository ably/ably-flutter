import Foundation


class Message: NSObject {
    let message: Any
    let handle: Int
    
    @objc
    init(message: Any, handle: Int) {
        self.message = message
        self.handle = handle
    }
}
