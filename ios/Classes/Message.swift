import Foundation

public class Message: NSObject {
    @objc
    public let message: Any
    @objc
    public let handle: NSNumber
    
    @objc
    public init(message: Any, handle: NSNumber) {
        self.message = message
        self.handle = handle
    }
}
