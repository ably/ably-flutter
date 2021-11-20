package io.ably.flutter.plugin;

import java.util.HashMap;

import io.ably.lib.util.Crypto;

/**
 * Stores and gets CipherParams by an Integer handle. On Android, ably-flutter will use this handle
 * to represent CipherParams on the Dart side. This is done because the CipherParams constructor is
 * private, and only ably-java can create them. When a method is called with CipherParams as an
 * argument, this Integer handle will be turned back into the CipherParams using
 * [CipherParamsStorage.from]. This only works when both methods are called on the same instance
 * of CipherParamsStorage, and not between app restarts.
 */
public class CipherParamsStorage {
  private Integer _nextHandle = 1;
  HashMap<Integer, Crypto.CipherParams> cipherParamsByHandle = new HashMap();

  /**
   * Store a cipherParams for as long as the CipherParamsStorage instance exists.
   *
   * @param params Instance of cipherParams to be stored at runtime.
   * @return a handle representing the CipherParams which lasts as long as CipherParamsStorage is
   * instantiated. It doesn't persist across app restarts.
   */
  public int getHandle(Crypto.CipherParams params) {
    cipherParamsByHandle.put(_nextHandle, params);
    return _nextHandle++;
  }

  /**
   * Gets the [CipherParams] instance from the Integer handle. Use this to get a CipherParams
   * when the Dart side provides only an Integer representing the CipherParams.
   * @param handle
   * @return
   */
  public Crypto.CipherParams from(int handle) {
    return cipherParamsByHandle.get(handle);
  }
}
