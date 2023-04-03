//
//  AuthHandlers.swift
//  ably_flutter
//
//  Created by Ikbal Kaya on 17/03/2023.
//

import Foundation

public class AuthHandlers: NSObject {
   
    
    @objc
    public static let realtimeAuthCreateTokenRequest: FlutterHandler = { ably, call, result in
        let ablyMessage = call.arguments as! AblyFlutterMessage
        let realtime = ably.instanceStore.realtime(from: ablyMessage.handle)
        
        if let push = getPush(instanceStore: ably.instanceStore, call: call, result: result) {
            PushActivationEventHandlers.getInstance(methodChannel: ably.channel).flutterResultForActivate = result
            push.activate()
        } else {
            result(FlutterError(code: "PushHandlers#activate", message: "Cannot get push from client", details: nil))
        }
    }
}
