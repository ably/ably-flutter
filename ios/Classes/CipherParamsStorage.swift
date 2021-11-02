import Foundation
import Ably

public class CipherParamsStorage: NSObject {
    private var _nextHandle: Int = 1
    private var cipherParamsByHandle: Dictionary<Int, ARTCipherParams> = Dictionary()
    
    @objc
    public func getHandle(params: ARTCipherParams) -> Int {
        let currentHandle = _nextHandle;
        cipherParamsByHandle[currentHandle] = params;
        _nextHandle += 1;
        return currentHandle;
    }
    
    @objc
    public func from(handle: Int) -> ARTCipherParams? {
        return cipherParamsByHandle[handle]
    }
}
