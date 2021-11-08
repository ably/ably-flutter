import 'dart:typed_data';

import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../../platform/platform.dart';
import '../crypto.dart';

/// Crypto related methods related to creating keys ([generateRandomKey]) and configuration
/// objects ([CipherParams]) for symmetric encryption.
class Crypto {
  static const DEFAULT_ALGORITHM = 'aes';
  static const DEFAULT_BLOCK_LENGTH_IN_BYTES = 16;
  static const DEFAULT_KEY_LENGTH = 256;
  static const DEFAULT_MODE = "cbc";
  static const KEY_TYPE_ERROR_MESSAGE =
      'A key must either be a String or a Uint8List.';

  /// Gets the CipherParams which can be used to with [RestChannelOptions] or
  /// [RealtimeChannelOptions] to specify encryption.
  ///
  ///  Pass a [String] containing a base64 encoded key or a [Uint8List]
  ///  containing raw bytes for the key. If you have a password, do not use it
  ///  directly, instead you should derive a key from this password,
  ///  for example by using a key derivation function (KDF) such as PBKDF2.
  static Future<CipherParams> getDefaultParams({required key}) async {
    if (key! is String && key! is Uint8List) {
      throw AblyException(KEY_TYPE_ERROR_MESSAGE);
    }

    return Platform.invokePlatformMethodNonNull<CipherParams>(
        PlatformMethod.cryptoGetParams, {
      TxCryptoGetParams.algorithm: DEFAULT_ALGORITHM,
      TxCryptoGetParams.key: key,
    });
  }

  /// Create a random key
  ///
  /// Specify a [keyLength] to choose how long the key is.
  /// Defaults to [DEFAULT_KEY_LENGTH].
  ///
  /// Warning: If you create a random key and encrypt messages without sharing
  /// this key with other clients, there is no way to decrypt the messages.
  static Future<Uint8List> generateRandomKey({keyLength = DEFAULT_KEY_LENGTH}) {
    return Platform.invokePlatformMethodNonNull<Uint8List>(
        PlatformMethod.cryptoGenerateRandomKey, keyLength);
  }
}
