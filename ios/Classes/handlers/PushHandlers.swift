import Foundation

public class PushHandlers: NSObject {
    @objc
    public static var pushNotificationTapLaunchedAppFromTerminatedData: Dictionary<AnyHashable, Any>? = nil;
    
    @objc
    public static let activate: FlutterHandler = { ably, call, result in
        if (PushActivationEventHandlers.getInstance(methodChannel: ably.channel).flutterResultForActivate != nil) {
            returnMethodAlreadyRunningError(result: result, methodName: "activate")
        } else if let push = getPush(ably: ably.instanceStore, call: call, result: result) {
            PushActivationEventHandlers.getInstance(methodChannel: ably.channel).flutterResultForActivate = result
            push.activate()
        }
    }

    @objc
    public static let deactivate: FlutterHandler = { ably, call, result in
        if (PushActivationEventHandlers.getInstance(methodChannel: ably.channel).flutterResultForDeactivate != nil) {
            returnMethodAlreadyRunningError(result: result, methodName: "deactivate")
        } else if let push = getPush(ably: ably.instanceStore, call: call, result: result) {
            PushActivationEventHandlers.getInstance(methodChannel: ably.channel).flutterResultForDeactivate = result
            push.deactivate()
        }
    }

    @objc
    public static let getNotificationSettings: (_ ably: AblyFlutter, _ call: FlutterMethodCall, _ result: @escaping (_ result: Any?) -> Void) -> Void = { ably, call, result in
        UNUserNotificationCenter.current().getNotificationSettings { [result] settings in
            result(settings)
        }
    }
    
    private static func returnMethodAlreadyRunningError(result: FlutterResult, methodName: String) {
        let error = FlutterError(code: "methodAlreadyRunning", message: "\(methodName) already running. Do not attempt to call \(methodName) before the previous call completes", details: nil)
        result(error)
    }

    @objc
    public static let requestPermission: FlutterHandler = { ably, call, result in
        let message = call.arguments as! AblyFlutterMessage
        let messageData = message.message as! AblyFlutterMessage
        let dataMap = messageData.message as! Dictionary<String, Any>

        var options: UNAuthorizationOptions = []

        if (dataMap[TxPushRequestPermission_badge] as! Bool) {
            options.insert(.badge)
        }
        if (dataMap[TxPushRequestPermission_sound] as! Bool) {
            options.insert(.sound)
        }
        if (dataMap[TxPushRequestPermission_alert] as! Bool) {
            options.insert(.alert)
        }
        if (dataMap[TxPushRequestPermission_carPlay] as! Bool) {
            options.insert(.carPlay)
        }
        if (dataMap[TxPushRequestPermission_criticalAlert] as! Bool) {
            if #available(iOS 12.0, *) {
                options.insert(.criticalAlert)
            }
        }
        if (dataMap[TxPushRequestPermission_provisional] as! Bool) {
            if #available(iOS 12.0, *) {
                options.insert(.provisional)
            }
        }
        if (dataMap[TxPushRequestPermission_providesAppNotificationSettings] as! Bool) {
            if #available(iOS 12.0, *) {
                options.insert(.providesAppNotificationSettings)
            }
        }
        if (dataMap[TxPushRequestPermission_announcement] as! Bool) {
            if #available(iOS 13.0, *) {
                options.insert(.announcement)
            }
        }

        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            guard error == nil else {
                result(FlutterError(code: String(error!._code), message: "Error requesting authorization to show user notifications; err = \(error!.localizedDescription)", details: nil))
                return
            }
            result(NSNumber(booleanLiteral: granted))
        }
    }

    @objc
    public static let device: FlutterHandler = { ably, call, result in
        let message = call.arguments as! AblyFlutterMessage
        let ablyClientHandle = message.message as! NSNumber
        let realtime = ably.instanceStore.realtime(from: ablyClientHandle)
        let rest = ably.instanceStore.rest(from: ablyClientHandle)

        if let realtime = realtime {
            result(realtime.device)
        } else if let rest = rest {
            result(rest.device)
        }
    }

    @objc
    public static let listSubscriptions: FlutterHandler = { ably, call, result in
        let message = call.arguments as! AblyFlutterMessage
        let nestedMessage = message.message as! AblyFlutterMessage
        let dataMap = nestedMessage.message as! Dictionary<String, Any>
        let params = dataMap[TxTransportKeys_params] as! Dictionary<String, String>

        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            do {
                try pushChannel.listSubscriptions(params, callback: { paginatedSubscription, errorInfo in
                    if let errorInfo = errorInfo {
                        result(FlutterError(code: String(errorInfo.code), message: "Error listing subscriptions from push Channel \(pushChannel); err = \(errorInfo.message)", details: nil))
                        return
                    }
                    let handle = ably.instanceStore.setPaginatedResult(paginatedSubscription as! ARTPaginatedResult<AnyObject>, handle: nil)
                    result(AblyFlutterMessage(message: paginatedSubscription as Any, handle: handle))
                })
            } catch {
                result(FlutterError(code: "listSubscriptions_error", message: "Error listing subscriptions from push Channel \(pushChannel); err = \(error.localizedDescription)", details: nil))
            }
        }
    }

    @objc
    public static let subscribeDevice: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.subscribeDevice()
            result(nil)
        }
    }

    @objc
    public static let unsubscribeDevice: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.unsubscribeDevice()
            result(nil)
        }
    }

    @objc
    public static let subscribeClient: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.subscribeClient()
            result(nil)
        }
    }

    @objc
    public static let unsubscribeClient: FlutterHandler = { ably, call, result in
        if let pushChannel = getPushChannel(ably: ably, call: call, result: result) {
            pushChannel.unsubscribeClient()
            result(nil)
        }
    }
    
    @objc
    public static let pushNotificationTapLaunchedAppFromTerminated: FlutterHandler = { ably, call, result in
        if let data = pushNotificationTapLaunchedAppFromTerminatedData {
            result(pushNotificationTapLaunchedAppFromTerminatedData)
        }
    }

    /// Gets the client.push property from ARTRealtime or ARTRest when the call contains a handle.
    private static func getPush(instanceStore: AblyInstanceStore, call: FlutterMethodCall, result: @escaping FlutterResult) -> ARTPush? {
        let message = call.arguments as! AblyFlutterMessage
        let ablyClientHandle = message.message as! NSNumber
        let realtime = instanceStore.realtime(from: ablyClientHandle)
        let rest = instanceStore.rest(from: ablyClientHandle)

        if let realtime = realtime {
            return realtime.push;
        }

        if let rest = rest {
            return rest.push;
        }

        result(FlutterError(code: String(40000), message: "No ably client exists (rest or realtime)", details: nil))
        return nil;
    }

    /// Gets the client.channels.get(channelName).push property from ARTRealtime or ARTRest
    /// when the call contains the clients handle and a channelName.
    ///
    /// The dart side can provide a handle (Int) which gets a ARTRealtime or ARTRest Ably client.
    /// This function will callback the with the push channel for the channelName and client handle you provide.
    private static func getPushChannel(ably: AblyFlutter, call: FlutterMethodCall, result: @escaping FlutterResult) -> ARTPushChannel? {
        let instanceStore = ably.instanceStore
        let message = call.arguments as! AblyFlutterMessage

        var clientHandle: NSNumber? = nil;
        var channelName: String? = nil;

        if let ablyFlutterMessage = message.message as? AblyFlutterMessage {
            if let nestedAblyFlutterMessage = ablyFlutterMessage.message as? AblyFlutterMessage {
                clientHandle = nestedAblyFlutterMessage.handle
                let dictionary = nestedAblyFlutterMessage.message as! Dictionary<String, Any>
                channelName = (dictionary[TxTransportKeys_channelName] as! String)
            } else if let dictionary = ablyFlutterMessage.message as? Dictionary<String, Any> {
                clientHandle = ablyFlutterMessage.handle
                channelName = (dictionary[TxTransportKeys_channelName] as! String)
            }
        } else {
            clientHandle = (message.message as! NSNumber)
        }

        guard let unwrappedClientHandle = clientHandle else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "clientHandle was null", details: nil))
            return nil
        }
        guard let unwrappedChannelName = channelName else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "channelName was null", details: nil))
            return nil
        }

        let realtime = instanceStore.realtime(from: unwrappedClientHandle)
        if let unwrappedRealtime = realtime {
            return unwrappedRealtime.channels.get(unwrappedChannelName).push
        } else if let unwrappedRest = instanceStore.rest(from: unwrappedClientHandle) {
            return unwrappedRest.channels.get(unwrappedChannelName).push
        } else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "No ably client (rest or realtime) exists for that handle.", details: nil))
            return nil
        }
    }
}
