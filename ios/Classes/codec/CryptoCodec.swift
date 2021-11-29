import Ably
import Foundation

public class CryptoCodec: NSObject {
    @objc
    public static let readCipherParams: ([String: Any]) -> ARTCipherParams = { dictionary in
        let algorithm = dictionary[TxCipherParams_iosAlgorithm] as! String
        let key = dictionary[TxCipherParams_iosKey] as! FlutterStandardTypedData
        return ARTCipherParams(algorithm: algorithm, 
        key: key.data as NSData)
    }   
    

    @objc
    public static let encodeCipherParams: (ARTCipherParams) -> [String: Any] = { cipherParams in
        [
            TxCipherParams_iosKey: cipherParams.key,
            TxCipherParams_iosAlgorithm: cipherParams.algorithm,
        ]
    }

    @objc
    public static let readRealtimeChannelOptions: ([String: Any]) -> ARTRealtimeChannelOptions = { dictionary in
        var channelOptions: ARTRealtimeChannelOptions
        if let cipherParamsDictionary = dictionary[TxRealtimeChannelOptions_cipherParams] as? [String: Any] {
            channelOptions = ARTRealtimeChannelOptions(cipher: readCipherParams(cipherParamsDictionary))
        } else {
            channelOptions = ARTRealtimeChannelOptions()
        }

        channelOptions.params = dictionary[TxRealtimeChannelOptions_params] as? [String: String]
        let modesStrings = dictionary[TxRealtimeChannelOptions_modes] as? [String]
        channelOptions.modes = []
        modesStrings?.forEach { mode in
            if let mode = ARTChannelMode.from(mode: mode) {
                channelOptions.modes.insert(mode)
            }
        }
        return channelOptions
    }

    @objc
    public static let readRestChannelOptions: ([String: Any]) -> ARTChannelOptions = { dictionary in
        if let cipherParamsDictionary = dictionary[TxRestChannelOptions_cipherParams] as? [String: Any] {
            return ARTChannelOptions(cipher: readCipherParams(cipherParamsDictionary))
        } else {
            return ARTChannelOptions()
        }
    }
}

extension ARTChannelMode {
    static func from(mode: String) -> ARTChannelMode? {
        switch mode {
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

    func toString() -> [String] {
        var modes: [String] = []
        if contains(ARTChannelMode.presence) {
            modes.append(TxEnumConstants_presence)
        }
        if contains(ARTChannelMode.subscribe) {
            modes.append(TxEnumConstants_subscribe)
        }
        if contains(ARTChannelMode.publish) {
            modes.append(TxEnumConstants_publish)
        }
        if contains(ARTChannelMode.presenceSubscribe) {
            modes.append(TxEnumConstants_presenceSubscribe)
        }
        return modes
    }
}
