import 'dart:typed_data';

import 'package:ably_flutter/src/crypto/src/cipher_params_native.dart';

import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../../platform/platform.dart';
import '../../authentication/authentication.dart';

class Crypto {
  static const DEFAULT_ALGORITHM = 'aes';
  static const DEFAULT_BLOCK_LENGTH_IN_BYTES = 16;

  /// Gets the CipherParams which can be used to with [RestChannelOptions] or
  /// [RealtimeChannelOptions] to specify encryption.
  ///
  /// params:
  /// key: String or Uint8List
  /// algorithm: A encryption specification which specifies a symmetric key algorithm
  /// initializationVector: Cryptographic primitive used to provide initial state.
  static Future<CipherParams> getParams({
    required dynamic key,
    String algorithm = DEFAULT_ALGORITHM,
    Uint8List? initializationVector,
  }) async {
    if (key != null && key! is String && key! is Uint8List) {
      throw AblyException('A key must either be a String or a Uint8List.');
    }

    final cipherParamsHandle = await Platform.invokePlatformMethodNonNull<int>(PlatformMethod.cryptoGetParams, {
      TxCryptoGetParams.algorithm: algorithm,
      TxCryptoGetParams.key: key,
      TxCryptoGetParams.initializationVector: initializationVector
    });
    return CipherParamsNative(handle: cipherParamsHandle).toCipherParams();
  }
}

