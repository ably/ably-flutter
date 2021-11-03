import 'cipher_params.dart';

class CipherParamsNative implements CipherParams {
  int handle;

  CipherParamsNative(
      {required this.handle,
      required this.algorithm,
      required this.keyLength,
      required this.mode});

  static getHandleFromCipherParams(CipherParams cipherParams) {
    return (cipherParams as CipherParamsNative).handle;
  }

  /// Explicitly cast the [CipherParamsNative] to [CipherParams] so users do not
  /// see implementation details (e.g. [handle]).
  CipherParams toCipherParams() => this;

  @override
  String algorithm;

  @override
  int keyLength;

  @override
  String mode;
}
