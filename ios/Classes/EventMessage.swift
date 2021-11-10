import Foundation

public class EventMessage: NSObject {
    @objc
    public let eventName: String
    @objc
    public let message: Any
    @objc
    public let handle: Int
    
    @objc
    public init(eventName: String, message: Any, handle: Int) {
        self.eventName = eventName
        self.message = message
        self.handle = handle
    }
}
