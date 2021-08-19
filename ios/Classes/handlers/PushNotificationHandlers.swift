//
//  PushNotificationHandlers.swift
//  ably_flutter
//
//  Created by Ben Butterworth on 19/08/2021.
//

import Foundation

public typealias FlutterHandler = (_ plugin: AblyFlutterPlugin, _ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void

public class PushNotificationHandlers: NSObject {
    @objc
    public static let activate: FlutterHandler = { plugin, call, result in
        let push = getPushFromAblyClient(ably: plugin.ably, call: call)
        if let push = push {
            push.activate()
            result(nil)
        } else {
            result(FlutterError(code: String(40000), message: "No ably client exists (rest or realtime)", details: nil))
        }
    }
    
    @objc
    public static let deactivate: FlutterHandler = { plugin, call, result in
        let push = getPushFromAblyClient(ably: plugin.ably, call: call)
        if let push = push {
            push.deactivate()
            result(nil)
        } else {
            result(FlutterError(code: String(40000), message: "No ably client exists (rest or realtime)", details: nil))
        }
    }
    
    @objc
    public static let getNotificationSettings: FlutterHandler = { plugin, call, result in
        UNUserNotificationCenter.current().getNotificationSettings { [result] settings in
            result(settings)
        }
    }
    
    @objc
    public static let requestPermission: FlutterHandler = { plugin, call, result in
        let message = call.arguments as! AblyFlutterMessage
        let messageData = message.message as! AblyFlutterMessage
        let dataMap = messageData.message as! Dictionary<String, Any>
        
        var options: UNAuthorizationOptions = []
        
        dataMap.forEach { key, value in
            switch(key) {
            case TxPushRequestPermission_badge:
                options.insert(.badge)
            case TxPushRequestPermission_sound:
                options.insert(.sound)
            case TxPushRequestPermission_alert:
                options.insert(.alert)
            case TxPushRequestPermission_carPlay:
                options.insert(.carPlay)
            case TxPushRequestPermission_criticalAlert:
                if #available(iOS 12.0, *) {
                    options.insert(.criticalAlert)
                }
            case TxPushRequestPermission_provisional:
                if #available(iOS 12.0, *) {
                    options.insert(.provisional)
                }
            case TxPushRequestPermission_announcement:
                if #available(iOS 13.0, *) {
                    options.insert(.announcement)
                }
            default:
                break
            }
        }
        
        if (dataMap[TxPushRequestPermission_badge] as! Bool) {
            options.insert(.badge)
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
    public static let device: FlutterHandler = { plugin, call, result in
        let message = call.arguments as! AblyFlutterMessage
        let ablyClientHandle = message.message as! NSNumber
        let realtime = plugin.ably.realtime(withHandle: ablyClientHandle)
        let rest = plugin.ably.getRest(ablyClientHandle)
        
        if let realtime = realtime {
            result(realtime.device)
        } else if let rest = rest {
            result(rest.device)
        }
    }
    
    @objc
    public static let listSubscriptions: FlutterHandler = { plugin, call, result in
        let message = call.arguments as! AblyFlutterMessage
        let nestedMessage = message.message as! AblyFlutterMessage
        let dataMap = nestedMessage.message as! Dictionary<String, Any>
        let params = dataMap[TxTransportKeys_params] as! Dictionary<String, String>
        
        if let pushChannel = getAblyPushChannel(plugin: plugin, call: call, result: result) {
            do {
                try pushChannel.listSubscriptions(params, callback: { paginatedSubscription, errorInfo in
                    if let errorInfo = errorInfo {
                        result(FlutterError(code: String(errorInfo.code), message: "Error listing subscriptions from push Channel \(pushChannel); err = \(errorInfo.message)", details: nil))
                        return
                    }
                    let handle = plugin.ably.setPaginatedResult(paginatedSubscription as! ARTPaginatedResult<AnyObject>, handle: nil)
                    result(AblyFlutterMessage(message: paginatedSubscription, handle: handle))
                })
            } catch {
                result(FlutterError(code: "listSubscriptions_error", message: "Error listing subscriptions from push Channel \(pushChannel); err = \(error.localizedDescription)", details: nil))
            }
        }
    }
    
    @objc
    public static let subscribeDevice: FlutterHandler = { plugin, call, result in
        if let pushChannel = getAblyPushChannel(plugin: plugin, call: call, result: result) {
            pushChannel.subscribeDevice()
            result(nil)
        }
    }
    
    @objc
    public static let unsubscribeDevice: FlutterHandler = { plugin, call, result in
        if let pushChannel = getAblyPushChannel(plugin: plugin, call: call, result: result) {
            pushChannel.unsubscribeDevice()
            result(nil)
        }
    }
    
    @objc
    public static let subscribeClient: FlutterHandler = { plugin, call, result in
        if let pushChannel = getAblyPushChannel(plugin: plugin, call: call, result: result) {
            pushChannel.subscribeClient()
            result(nil)
        }
    }
    
    @objc
    public static let unsubscribeClient: FlutterHandler = { plugin, call, result in
        if let pushChannel = getAblyPushChannel(plugin: plugin, call: call, result: result) {
            pushChannel.unsubscribeClient()
            result(nil)
        }
    }
    
    private static func getPushFromAblyClient(ably: AblyFlutter, call: FlutterMethodCall) -> ARTPush? {
        let message = call.arguments as! AblyFlutterMessage
        let ablyClientHandle = message.message as! NSNumber
        let realtime = ably.realtime(withHandle: ablyClientHandle)
        let rest = ably.getRest(ablyClientHandle)
        
        if let realtime = realtime {
            return realtime.push;
        }
        
        if let rest = rest {
            return rest.push;
        }
        
        return nil;
    }

    /// The dart side can provide a handle (Int) which gets a ARTRealtime or ARTRest Ably client.
    /// This function will callback the with the push channel for the channelName and client handle you provide.
    private static func getAblyPushChannel(plugin: AblyFlutterPlugin, call: FlutterMethodCall, result: @escaping FlutterResult) -> ARTPushChannel? {
        let ably = plugin.ably
        let message = call.arguments as! AblyFlutterMessage
        // TODO Make AblyMessage usage consistent on Dart side, instead of nesting AblyMessages
        // See platform_object.dart invoke method: AblyMessage(AblyMessage(argument, handle: _handle))
        
        var clientHandle: NSNumber? = nil;
        var channelName: String? = nil;
        
        if let ablyFlutterMessage = message.message as? AblyFlutterMessage {
            if let nestedAblyFlutterMessage = ablyFlutterMessage.message as? AblyFlutterMessage {
                clientHandle = nestedAblyFlutterMessage.handle
                let dictionary = nestedAblyFlutterMessage.message as! Dictionary<String, Any>
                channelName = dictionary[TxTransportKeys_channelName] as! String
            } else if let dictionary = ablyFlutterMessage.message as? Dictionary<String, Any> {
                clientHandle = ablyFlutterMessage.handle
                channelName = dictionary[TxTransportKeys_channelName] as! String
            }
        } else {
            clientHandle = message.message as! NSNumber
        }
        
        guard let clientHandle = clientHandle else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "clientHandle was null", details: nil))
            return nil
        }
        guard let channelName = channelName else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "channelName was null", details: nil))
            return nil
        }
        
        let realtime = ably.realtime(withHandle: clientHandle)
        if let realtime = realtime {
            return realtime.channels.get(channelName).push
        } else if let rest = ably.getRest(clientHandle) {
            return rest.channels.get(channelName).push
        } else {
            result(FlutterError(code: "getAblyPushChannel_error", message: "No ably client (rest or realtime) exists for that handle.", details: nil))
            return nil
        }
    }
}
