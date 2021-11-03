import Foundation
import Ably

public class CryptoHandlers: NSObject {
    @objc
    public static let getParams: FlutterHandler = { plugin, call, result in
        let cipherParamsStorage = plugin.cipherParamsStorage
        let dictionary = call.arguments as! Dictionary<String, Any>
        let algorithm = dictionary[TxCryptoGetParams_algorithm] as! String
        let key = dictionary[TxCryptoGetParams_key]
        let initializationVector = dictionary[TxCryptoGetParams_initializationVector] as? FlutterStandardTypedData
        
        if let key = key as? NSString {
            let params = ARTCipherParams(algorithm: algorithm, key: key, iv: initializationVector?.data)
            let handle = cipherParamsStorage.getHandle(params: params)
            result(handle)
        } else if let key = key as? FlutterStandardTypedData {
            let params = ARTCipherParams(algorithm: algorithm, key: key.data as NSData, iv: initializationVector?.data)
            let handle = cipherParamsStorage.getHandle(params: params)
            result(handle)
        } else if let key = key {
            result(FlutterError(code: "CryptoHandlers_getParams", message: "Key must be a String or FlutterStandardTypedData, it is \(type(of: key))", details: nil))
        } else {
            result(FlutterError(code: "CryptoHandlers_getParams", message: "A key must be set for encryption", details: nil))
        }
    }
    
    @objc
    public static let channelOptionsWithCipherKey: FlutterHandler = { plugin, call, result in
        let cipherKey = call.arguments;
        
        if let cipherKey = cipherKey as? FlutterStandardTypedData {
            let options = ARTRealtimeChannelOptions(cipherKey: cipherKey.data as ARTCipherKeyCompatible)
        } else if let cipherKey = cipherKey as? String {
            let options = ARTRealtimeChannelOptions(cipherKey: cipherKey as ARTCipherKeyCompatible)
        } else {
            result(FlutterError(code: "CryptoHandlers_channelOptionsWithCipherKey", message: "Cipher must be a FlutterStandardTypedData or a String", details: nil))
        }
    }
    
    @objc
    public static let generateRandomKey: FlutterHandler = { plugin, call, result in
        let keyLength = call.arguments as! Int;
        result(ARTCrypto.generateRandomKey(UInt(keyLength)));
    }
}
