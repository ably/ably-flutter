//
//  PushActivationEventHandlers.swift
//  ably_flutter
//
//  Created by Ben Butterworth on 21/08/2021.
//

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
        if let instance = PushActivationEventHandlers.instance {
            return instance
        }
        return PushActivationEventHandlers(methodChannel: methodChannel)
    }
    
    // FlutterResults to return result as Future<void> or throws an error. This is the convenient API.
    public var flutterResultForActivate: FlutterResult? = nil;
    public var flutterResultForDeactivate: FlutterResult? = nil;
    // There is no result available for didAblyPushRegistrationFail, because there is dart side method call.
    
    // MethodChannel to send result to handlers implemented in dart side. This handles the case
    // where . We need this for activate and deactivate because the new token can be provided.
    // We probably don't need this for deactivate, since it will happen immediately,
    // and the return values will be sufficient.
    // TODO does ably-flutter have a way to call methods to dart side currently?
    private var methodChannel: FlutterMethodChannel
    
    public func didActivateAblyPush(_ error: ARTErrorInfo?) {
        guard let result = flutterResultForActivate else {
            // TODO throw no flutterResult to give back the result. This is a SDK developer error.
            return
        }
        if let error = error {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnActivate, arguments: error, result: nil)
            result(FlutterError(code: String(error.code), message: error.message, details: error))
        } else {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnActivate, arguments: nil, result: nil)
            result(nil)
        }
        flutterResultForActivate = nil
    }
    
    public func didDeactivateAblyPush(_ error: ARTErrorInfo?) {
        guard let result = flutterResultForDeactivate else {
            // TODO throw no flutterResult to give back the result. This is a SDK developer error.
            return
        }
        if let error = error {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnDeactivate, arguments: error, result: nil)
            result(FlutterError(code: String(error.code), message: error.message, details: error))
        } else {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnDeactivate, arguments: nil, result: nil)
            result(nil)
        }
        flutterResultForDeactivate = nil
    }
    
    public func didAblyPushRegistrationFail(_ error: ARTErrorInfo?) {
        if let error = error {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnUpdateFailed, arguments: error, result: nil)
        } else {
            methodChannel.invokeMethod(AblyPlatformMethod_pushOnUpdateFailed, arguments: FlutterError(code: "40000", message: "Ably push update failed, but no error was provided", details: nil), result: nil)
        }
    }
}
