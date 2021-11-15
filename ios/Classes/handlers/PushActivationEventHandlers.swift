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
    // These fields are set in [PushHandlers.swift] when the method call is invoked
    public var flutterResultForActivate: FlutterResult? = nil;
    public var flutterResultForDeactivate: FlutterResult? = nil;
    // There is no result stored for didAblyPushRegistrationFail, because there is no dart side method call to return values to.
    
    // MethodChannel to send result to handlers implemented in dart side. This provides values to the listeners
    // implement on the dart side. We need this for activate and deactivate because the new token can be provided.
    // We probably don't need this for deactivate, since it will happen immediately,
    // and the return values will be sufficient.
    private var methodChannel: FlutterMethodChannel
    
    public func didActivateAblyPush(_ error: ARTErrorInfo?) {
        defer {
            flutterResultForActivate = nil
        }

        methodChannel.invokeMethod(AblyPlatformMethod_pushOnActivate, arguments: error, result: nil)
        if let result = flutterResultForActivate {
            result(error)
        } else {
            print("Did not return a value asynchronously because flutterResultForActivate was nil. The app might have been restarted since calling activate.")
        }
    }
    
    public func didDeactivateAblyPush(_ error: ARTErrorInfo?) {
        defer {
            flutterResultForDeactivate = nil
        }

        methodChannel.invokeMethod(AblyPlatformMethod_pushOnDeactivate, arguments: error, result: nil)
        if let result = flutterResultForDeactivate {
            result(error)
        } else {
            print("Did not return a value asynchronously because flutterResultForDeactivate was nil. The app might have been restarted since calling deactivate.")
        }
    }
    
    public func didAblyPushRegistrationFail(_ error: ARTErrorInfo?) {
        methodChannel.invokeMethod(AblyPlatformMethod_pushOnUpdateFailed, arguments: error, result: nil)
    }
}
