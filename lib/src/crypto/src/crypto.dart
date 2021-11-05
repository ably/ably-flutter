import 'dart:typed_data';

import '../../authentication/authentication.dart';
import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../../platform/platform.dart';
import '../crypto.dart';

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
  static Future<CipherParams> getDefaultParams({required key}) async {
    if (key! is String && key! is Uint8List) {
      throw AblyException('A key must either be a String or a Uint8List.');
    }

    return Platform.invokePlatformMethodNonNull<CipherParams>(
        PlatformMethod.cryptoGetParams, {
      TxCryptoGetParams.algorithm: DEFAULT_ALGORITHM,
      TxCryptoGetParams.key: key,
    });
  }

  static Future<Uint8List> generateRandomKey({keyLength = DEFAULT_KEY_LENGTH}) {
    return Platform.invokePlatformMethodNonNull<Uint8List>(
        PlatformMethod.cryptoGenerateRandomKey, keyLength);
  }
}
