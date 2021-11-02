import Foundation
import Ably

public class CryptoCodec: NSObject {
private let cipherParamsStorage: CipherParamsStorage
    
    init(cipherParamsStorage: CipherParamsStorage) {
        self.cipherParamsStorage = cipherParamsStorage
    }
    
    @objc
    public func readRealtimeChannelOptions(dictionary: Dictionary<String, Any>) -> ARTRealtimeChannelOptions {
        let cipherParamsHandle = dictionary[TxRealtimeChannelOptions_cipherParamsHandle] as? Int
        var channelOptions: ARTRealtimeChannelOptions
        if let handle = cipherParamsHandle {
            let params = self.cipherParamsStorage.from(handle: handle)!
            channelOptions = ARTRealtimeChannelOptions(cipher: params)
        } else {
            channelOptions = ARTRealtimeChannelOptions()
        }
        
        channelOptions.params = dictionary[TxRealtimeChannelOptions_params] as? Dictionary<String, String>
        
        let modesStrings = dictionary[TxRealtimeChannelOptions_modes] as! [String]
        channelOptions.modes = []
        modesStrings.forEach { mode in
            if let mode = ARTChannelMode.from(mode: mode) {
                channelOptions.modes.insert(mode)
            }
        }
        return channelOptions
    }
    
    @objc
    public func readRestChannelOptions(dictionary: Dictionary<String, Any>) -> ARTChannelOptions {
        let cipherParamsHandle = dictionary[TxRestChannelOptions_cipherParamsHandle] as? Int
        var channelOptions: ARTChannelOptions
        if let handle = cipherParamsHandle {
            let params = self.cipherParamsStorage.from(handle: handle)!
            channelOptions = ARTChannelOptions(cipher: params)
        } else {
            channelOptions = ARTChannelOptions()
        }
        return channelOptions
    }

}

extension ARTChannelMode {
    static func from(mode: String) -> ARTChannelMode? {
        switch(mode) {
        case TxEnumConstants_presence:
            return ARTChannelMode.presence
        case TxEnumConstants_subscribe:
            return ARTChannelMode.subscribe
        case TxEnumConstants_publish:
            return ARTChannelMode.publish
        case TxEnumConstants_presenceSubscribe:
            return ARTChannelMode.presenceSubscribe
        default: return nil
        }
        
    }
}
