import 'dart:typed_data';

import '../../authentication/authentication.dart';
import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../../platform/platform.dart';
import 'cipher_params_native.dart';

class Crypto {
  static const DEFAULT_ALGORITHM = 'aes';
  static const DEFAULT_BLOCK_LENGTH_IN_BYTES = 16;
  static const DEFAULT_KEY_LENGTH = 256;
  static const DEFAULT_MODE = "cbc";

  /// Gets the CipherParams which can be used to with [RestChannelOptions] or
  /// [RealtimeChannelOptions] to specify encryption.
  ///
  /// params:
  ///  key: String of a base64 encoded key or a Uint8List containing raw bytes for the key.
  ///  algorithm: A encryption specification which specifies a symmetric key algorithm
  ///  initializationVector: Cryptographic primitive used to provide initial state.
  static Future<CipherParams> getParams({
    required key,
    Uint8List? initializationVector,
  }) async {
    if (key! is String && key! is Uint8List) {
      throw AblyException('A key must either be a String or a Uint8List.');
    }

    final cipherParamsHandle = await Platform.invokePlatformMethodNonNull<int>(
        PlatformMethod.cryptoGetParams, {
      TxCryptoGetParams.algorithm: DEFAULT_ALGORITHM,
      TxCryptoGetParams.key: key,
      TxCryptoGetParams.initializationVector: initializationVector
    });
    // TODO get all the fields from native side. And set them instead of using defaults.
    return CipherParamsNative(
            handle: cipherParamsHandle,
            algorithm: DEFAULT_ALGORITHM,
            keyLength: DEFAULT_KEY_LENGTH,
            mode: DEFAULT_MODE)
        .toCipherParams();
  }

  static Future<Uint8List> generateRandomKey({keyLength = DEFAULT_KEY_LENGTH}) {
    return Platform.invokePlatformMethodNonNull<Uint8List>(
        PlatformMethod.cryptoGenerateRandomKey, keyLength);
  }
}
