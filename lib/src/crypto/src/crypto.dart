import 'dart:typed_data';

import 'package:ably_flutter/src/crypto/src/cipher_params_native.dart';

import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../../platform/platform.dart';
import '../../authentication/authentication.dart';

class Crypto {
  static const DEFAULT_ALGORITHM = 'aes';
  static const DEFAULT_KEY_LENGTH_IN_BITS = 128;
  static const DEFAULT_BLOCK_LENGTH_IN_BYTES = 16;

  /**
   * Gets the CipherParams which can be used to pass
   *
   * params:
   * key: null, String or Uint8List. If a key is unspecified (null), a
   *   locally generated key will be used.
   * algorithm: A encryption specification which specifies a symmetric key algorithm
   * initializationVector: Cryptographic primitive used to provide initial state.
   */
  static Future<CipherParams> getParams({
    dynamic key,
    int keyLength = DEFAULT_KEY_LENGTH_IN_BITS,
    String algorithm = DEFAULT_ALGORITHM,
    Uint8List? initializationVector,
  }) async {
    if (key != null && key! is String && key! is Uint8List) {
      throw AblyException('A key must either be null, a String or a Uint8List. '
          'If a key is unspecified (null), '
          'a locally generated key will be used.');
    }

    final cipherParamsHandle = await Platform.invokePlatformMethodNonNull<int>(PlatformMethod.cryptoGetParams, {
      TxCryptoGetParams.algorithm: algorithm,
      TxCryptoGetParams.key: key,
      TxCryptoGetParams.keyLength: keyLength,
      TxCryptoGetParams.initializationVector: initializationVector
    });
    return CipherParamsNative(handle: cipherParamsHandle) as CipherParams;
  }
}

