import Foundation
import Ably

// This class provide results back to Dart side in 2 ways, simultaneously:
  // 1. Return value to activate(). To do this, we need to give it `result`. Users can await method() and expect the result to throw or succeed.
  // 2. Send the value to the handlers on the dart side which the user set. Users set a callback
  //  on the dart side when the application launches.
public class PushActivationEventHandlers: NSObject, ARTPushRegistererDelegate {
    
    init(methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
    }
    
    private static var instance: PushActivationEventHandlers?;
    @objc public static func getInstance(methodChannel: FlutterMethodChannel) -> PushActivationEventHandlers {
        if instance == nil {
            instance = PushActivationEventHandlers(methodChannel: methodChannel)
        }
        return instance!
    }
    
    // FlutterResults to return result as Future<void> or throws an error. This is the convenient API.
    public var flutterResultForActivate: FlutterResult? = nil;
    public var flutterResultForDeactivate: FlutterResult? = nil;
    // There is no result stored for didAblyPushRegistrationFail, because there is dart side method call to return values to.
    
    // MethodChannel to send result to handlers implemented in dart side. This provides values to the listeners
    // implement on the dart side. We need this for activate and deactivate because the new token can be provided.
    // We probably don't need this for deactivate, since it will happen immediately,
    // and the return values will be sufficient.
    private var methodChannel: FlutterMethodChannel
    
    public func didActivateAblyPush(_ error: ARTErrorInfo?) {
        defer {
            flutterResultForDeactivate = nil
        }
        
        guard let result = flutterResultForActivate else {
            let error = FlutterError(code: "didActivateAblyPush_error", message: "Failed to asynchronously return a value because flutterResultForActivate was nil", details: nil)
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnActivate, arguments: error, result: nil)
            return
        }
        if let error = error {
            result(FlutterError(code: String(error.code), message: error.message, details: error))
        } else {
            result(nil)
        }
        methodChannel.invokeMethod(AblyPlatformMethod_pushOnActivate, arguments: error, result: nil)
    }
    
    public func didDeactivateAblyPush(_ error: ARTErrorInfo?) {
        defer {
            flutterResultForDeactivate = nil
        }
        
        guard let result = flutterResultForDeactivate else {
            let error = FlutterError(code: "didDeactivateAblyPush_error", message: "Failed to asynchronously return a value because flutterResultForDeactivate was nil", details: nil)
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnDeactivate, arguments: error, result: nil)
            return
        }
        if let error = error {
            result(FlutterError(code: String(error.code), message: error.message, details: error))
        } else {
            result(nil)
        }
        methodChannel.invokeMethod(AblyPlatformMethod_pushOnDeactivate, arguments: error, result: nil)
    }
    
    public func didAblyPushRegistrationFail(_ error: ARTErrorInfo?) {
        if let error = error {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnUpdateFailed, arguments: error, result: nil)
        } else {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnUpdateFailed, arguments: FlutterError(code: "40000", message: "Ably push update failed, but no error was provided", details: nil), result: nil)
        }
    }
}
