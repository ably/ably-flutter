import Foundation

public class EventMessage: NSObject {
    @objc
    public let eventName: String
    @objc
    public let message: Any
    @objc
    public let handle: NSNumber
    
    @objc
    public init(eventName: String, message: Any, handle: NSNumber) {
        self.eventName = eventName
        self.message = message
        self.handle = handle
    }
}
