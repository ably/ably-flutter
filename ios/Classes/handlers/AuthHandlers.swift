//
//  AuthHandlers.swift
//  ably_flutter
//
//  Created by Ikbal Kaya on 17/03/2023.
//

import Foundation

public class AuthHandlers: NSObject {
   
    
    @objc
    public static let realtimeCreateTokenRequest: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: ARTAuthOptions?
        var tokenParams: ARTTokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? ARTAuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? ARTTokenParams
        }
        realtime?.auth.createTokenRequest(tokenParams, options: authOptions, callback: { (tokenRequest: ARTTokenRequest?, error: Error?) in
            if let error = error {
                result(error)
                return
            }
            result(tokenRequest)
        })
    }
    
    @objc
    public static let realtimeAuthClientId: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let clientId =  realtime?.auth.clientId
        result(clientId)
    }
    
    @objc
    public static let realtimeAuthorize: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: ARTAuthOptions?
        var tokenParams: ARTTokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? ARTAuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? ARTTokenParams
        }
        
        realtime?.auth.authorize(tokenParams, options: authOptions, callback: { (details:ARTTokenDetails?, error: Error?) in
            if let error = error {
                result(error)
                return
            }
            result(details)
            
        });
    }
    
    @objc
    public static let realtimeRequestToken: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: ARTAuthOptions?
        var tokenParams: ARTTokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? ARTAuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? ARTTokenParams
        }
        realtime?.auth.requestToken(tokenParams, with: authOptions, callback: { (details: ARTTokenDetails?, error: Error?) in
            if let error = error {
                           result(error)
                           return
                       }
                       result(details)
        })
    
    }
    
    
    @objc
    public static let restCreateTokenRequest: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let rest = ably.instanceStore.rest(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: ARTAuthOptions?
        var tokenParams: ARTTokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? ARTAuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? ARTTokenParams
        }
        rest?.auth.createTokenRequest(tokenParams, options: authOptions, callback: { (tokenRequest: ARTTokenRequest?, error: Error?) in
            if let error = error {
                result(error)
                return
            }
            result(tokenRequest)
        })
    }
    
    
    @objc
    public static let restAuthorize: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let rest = ably.instanceStore.rest(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: ARTAuthOptions?
        var tokenParams: ARTTokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? ARTAuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? ARTTokenParams
        }
        
        rest?.auth.authorize(tokenParams, options: authOptions, callback: { (details:ARTTokenDetails?, error: Error?) in
            if let error = error {
                result(error)
                return
            }
            result(details)
            
        });
    }
    
    @objc
    public static let restRequestToken: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let rest = ably.instanceStore.rest(from: ablyMessage.handle)
        let dataMap = ablyMessage.message as! Dictionary<String, Any>
        var authOptions: ARTAuthOptions?
        var tokenParams: ARTTokenParams?
        
        if let dataMap = ablyMessage.message as? Dictionary<String, Any> {
            authOptions = dataMap[TxTransportKeys_options] as? ARTAuthOptions
            tokenParams = dataMap[TxTransportKeys_params] as? ARTTokenParams
        }
        rest?.auth.requestToken(tokenParams, with: authOptions, callback: { (details: ARTTokenDetails?, error: Error?) in
            if let error = error {
                           result(error)
                           return
                       }
                       result(details)
        })
    
    }
    
    @objc
    public static let restAuthClientId: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let rest = ably.instanceStore.rest(from: ablyMessage.handle)
        let clientId =  rest?.auth.clientId
        result(clientId)
    }
}
