import Foundation

public class EventMessage: NSObject {
    let eventName: String
    let message: Any
    let handle: Int?
    
    init(eventName: String, message: Any, handle: Int?) {
        self.eventName = eventName
        self.message = message
        self.handle = handle
    }
    
    /// This convenience initializer is implemented to keep the initializer written in idiomatic Swift. Objective-C code should call methods like this marked with @objc in this file.
    /// This method can be removed once all Objective-C code is removed from the SDK
    @objc
    convenience public init(eventName: String, message: Any, handle: Int) {
        self.init(eventName: eventName, message: message, handle: nil)
    }
    
    /// This convenience initializer is implemented to keep the initializer written in idiomatic Swift. Objective-C code should call methods like this marked with @objc in this file.
    /// This method can be removed once all Objective-C code is removed from the SDK
    @objc
    convenience public init(eventName: String, message: Any) {
        self.init(eventName: eventName, message: message, handle: nil)
    }
}
