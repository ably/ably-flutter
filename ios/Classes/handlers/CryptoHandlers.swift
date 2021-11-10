import Foundation
import Ably

public class CryptoHandlers: NSObject {
    @objc
    public static let getParams: FlutterHandler = { plugin, call, result in
        let dictionary = call.arguments as! Dictionary<String, Any>
        let algorithm = dictionary[TxCryptoGetParams_algorithm] as! String
        let key = dictionary[TxCryptoGetParams_key]

        if let key = key as? NSString {
            result(ARTCipherParams(algorithm: algorithm, key: key))
            return
        } else if let key = key as? FlutterStandardTypedData {
            result(ARTCipherParams(algorithm: algorithm, key: key.data as NSData))
            return
        } else if let key = key {
            result(FlutterError(code: "CryptoHandlers_getParams", message: "Key must be a String or FlutterStandardTypedData, it is \(type(of: key))", details: nil))
        } else {
            result(FlutterError(code: "CryptoHandlers_getParams", message: "A key must be set for encryption", details: nil))
        }
    }
    
    @objc
    public static let generateRandomKey: FlutterHandler = { plugin, call, result in
        let keyLength = call.arguments as! Int;
        result(ARTCrypto.generateRandomKey(UInt(keyLength)));
    }
}
