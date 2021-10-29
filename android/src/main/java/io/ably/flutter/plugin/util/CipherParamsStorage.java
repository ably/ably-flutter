package io.ably.flutter.plugin.util;

import java.util.HashMap;

import io.ably.lib.util.Crypto;

/**
 * Stores references to CipherParams, because CipherParams constructor is private, and only Ably-Java
 * can create them.
 */
public class CipherParamsStorage {
  private Integer _nextHandle = 1;
  HashMap<Integer, Crypto.CipherParams> cipherParamsByHandle = new HashMap();

  public int getHandle(Crypto.CipherParams params) {
    cipherParamsByHandle.put(_nextHandle, params);
    return _nextHandle++;
  }

  public Crypto.CipherParams from(int handle) {
    return cipherParamsByHandle.get(handle);
  }
}
