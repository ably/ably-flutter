import 'cipher_params.dart';

class CipherParamsNative implements CipherParams {
  int handle;

  CipherParamsNative({required this.handle});

  static getHandleFromCipherParams(CipherParams cipherParams) {
    return (cipherParams as CipherParamsNative).handle;
  }
}
