import 'dart:convert';
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Utility methods for creating keys ([generateRandomKey]) and configuration
/// objects ([CipherParams]) for symmetric encryption.
class Crypto {
  /// Default algorithm used of encryption
  /// Currently only AES is supported
  static const defaultAlgorithm = 'aes';

  /// Default length of the key in bits
  /// Equals to [keyLength256bits]
  static const defaultKeyLengthInBits = keyLength256bits;

  /// Length of 256-bit key
  static const keyLength256bits = 256;

  /// Length of 128-bit key
  static const keyLength128bits = 128;

  /// Default mode used of encryption
  /// Currently only CBC is supported
  static const defaultMode = 'cbc';

  /// Gets the CipherParams which can be used to with [RestChannelOptions] or
  /// [RealtimeChannelOptions] to specify encryption.
  ///
  ///  Pass a [String] containing a base64 encoded key or a [Uint8List]
  ///  containing raw bytes for the key. This key must be 128 or 256 bits long.
  ///  If you have a password, do not use it directly, instead you should
  ///  derive a key from this password, for example by using a key derivation
  ///  function (KDF) such as PBKDF2.
  static Future<CipherParams> getDefaultParams({required dynamic key}) async {
    if (key is String) {
      ensureSupportedKeyLength(base64Decode(key));
    } else if (key is Uint8List) {
      ensureSupportedKeyLength(key);
    } else {
      throw AblyException(
        message: 'key must be a String or Uint8List.',
      );
    }

    return Platform().invokePlatformMethodNonNull<CipherParams>(
      PlatformMethod.cryptoGetParams,
      AblyMessage(message: {
        TxCryptoGetParams.algorithm: defaultAlgorithm,
        TxCryptoGetParams.key: key,
      }),
    );
  }

  /// Validates the length of provided [key]
  /// Throws [AblyException] if key length is different than 128 or 256 bits
  static void ensureSupportedKeyLength(Uint8List key) {
    if (key.length != keyLength256bits / 8 &&
        key.length != keyLength128bits / 8) {
      throw AblyException(
        message: 'Key must be 256 bits or 128 bits long.',
      );
    }
  }

  /// Create a random key
  ///
  /// Specify a [keyLength] to choose how long the key is.
  /// Defaults to [defaultKeyLengthInBits].
  ///
  /// Warning: If you create a random key and encrypt messages without sharing
  /// this key with other clients, there is no way to decrypt the messages.
  static Future<Uint8List> generateRandomKey({
    int keyLength = defaultKeyLengthInBits,
  }) =>
      Platform().invokePlatformMethodNonNull<Uint8List>(
        PlatformMethod.cryptoGenerateRandomKey,
        AblyMessage(message: {
          TxCryptoGenerateRandomKey.keyLength: keyLength,
        }),
      );
}
