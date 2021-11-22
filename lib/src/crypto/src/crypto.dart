import 'dart:convert';
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Utility methods for creating keys ([generateRandomKey]) and configuration
/// objects ([CipherParams]) for symmetric encryption.
class Crypto {
  static const defaultAlgorithm = 'aes';
  static const defaultBlockLengthInBytes = 16;
  static const defaultKeyLengthInBits = 256;
  static const keyLength128bits = 128;
  static const defaultMode = 'cbc';
  static const keyTypeErrorMessage = 'key must be a String or Uint8List.';
  static const keyLengthErrorMessage = 'key must be 256 bits or 128 bits long.';

  /// Gets the CipherParams which can be used to with [RestChannelOptions] or
  /// [RealtimeChannelOptions] to specify encryption.
  ///
  ///  Pass a [String] containing a base64 encoded key or a [Uint8List]
  ///  containing raw bytes for the key. This key must be 128 or 256 bits long.
  ///  If you have a password, do not use it directly, instead you should
  ///  derive a key from this password, for example by using a key derivation
  ///  function (KDF) such as PBKDF2.
  static Future<CipherParams> getDefaultParams({required key}) async {
    if (key is String) {
      ensureSupportedKeyLength(base64Decode(key));
    } else if (key is Uint8List) {
      ensureSupportedKeyLength(key);
    } else {
      throw AblyException(keyTypeErrorMessage);
    }

    return Platform.invokePlatformMethodNonNull<CipherParams>(
        PlatformMethod.cryptoGetParams, {
      TxCryptoGetParams.algorithm: defaultAlgorithm,
      TxCryptoGetParams.key: key,
    });
  }

  static void ensureSupportedKeyLength(Uint8List key) {
    if (key.length != defaultKeyLengthInBits / 8 &&
        key.length != keyLength128bits / 8) {
      throw AblyException(keyLengthErrorMessage);
    }
  }

  /// Create a random key
  ///
  /// Specify a [keyLength] to choose how long the key is.
  /// Defaults to [defaultKeyLengthInBits].
  ///
  /// Warning: If you create a random key and encrypt messages without sharing
  /// this key with other clients, there is no way to decrypt the messages.
  static Future<Uint8List> generateRandomKey(
          {keyLength = defaultKeyLengthInBits}) =>
      Platform.invokePlatformMethodNonNull<Uint8List>(
          PlatformMethod.cryptoGenerateRandomKey, keyLength);
}
