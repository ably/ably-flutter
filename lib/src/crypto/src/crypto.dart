import 'dart:convert';
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// Utility methods for creating keys ([generateRandomKey]) and configuration
/// objects ([CipherParams]) for symmetric encryption.
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains the properties required to configure the encryption of
/// [Message]{@link Message} payloads.
/// END CANONICAL DOCSTRING
class Crypto {
  /// BEGIN LEGACY DOCSTRING
  /// Default algorithm used of encryption
  /// Currently only AES is supported
  /// END LEGACY DOCSTRING
  static const defaultAlgorithm = 'aes';

  /// BEGIN LEGACY DOCSTRING
  /// Default length of the key in bits
  /// Equals to [keyLength256bits]
  /// END LEGACY DOCSTRING
  static const defaultKeyLengthInBits = keyLength256bits;

  /// BEGIN LEGACY DOCSTRING
  /// Length of 256-bit key
  /// END LEGACY DOCSTRING
  static const keyLength256bits = 256;

  /// BEGIN LEGACY DOCSTRING
  /// Length of 128-bit key
  /// END LEGACY DOCSTRING
  static const keyLength128bits = 128;

  /// BEGIN LEGACY DOCSTRING
  /// Default mode used of encryption
  /// Currently only CBC is supported
  /// END LEGACY DOCSTRING
  static const defaultMode = 'cbc';

  /// BEGIN LEGACY DOCSTRING
  /// Gets the CipherParams which can be used to with [RestChannelOptions] or
  /// [RealtimeChannelOptions] to specify encryption.
  ///
  ///  Pass a [String] containing a base64 encoded key or a [Uint8List]
  ///  containing raw bytes for the key. This key must be 128 or 256 bits long.
  ///  If you have a password, do not use it directly, instead you should
  ///  derive a key from this password, for example by using a key derivation
  ///  function (KDF) such as PBKDF2.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Returns a [CipherParams]{@link CipherParams} object, using the default
  /// values for any fields not supplied by the
  /// [CipherParamOptions]{@link CipherParamOptions} object.
  ///
  /// [CipherParamOptions] - A [CipherParamOptions]{@link CipherParamOptions}
  /// object.
  ///
  /// [CipherParams] - A [CipherParams]{@link CipherParams} object, using the
  /// default values for any fields not supplied.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// Validates the length of provided [key]
  /// Throws [AblyException] if key length is different than 128 or 256 bits
  /// END LEGACY DOCSTRING
  static void ensureSupportedKeyLength(Uint8List key) {
    if (key.length != keyLength256bits / 8 &&
        key.length != keyLength128bits / 8) {
      throw AblyException(
        message: 'Key must be 256 bits or 128 bits long.',
      );
    }
  }

  /// BEGIN LEGACY DOCSTRING
  /// Create a random key
  ///
  /// Specify a [keyLength] to choose how long the key is.
  /// Defaults to [defaultKeyLengthInBits].
  ///
  /// Warning: If you create a random key and encrypt messages without sharing
  /// this key with other clients, there is no way to decrypt the messages.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Generates a random key to be used in the encryption of the channel. If the
  /// language cryptographic randomness primitives are blocking or async, a
  /// callback is used. The callback returns a generated binary key.
  ///
  /// [keyLength] - The length of the key, in bits, to be generated. If not
  /// specified, this is equal to the default keyLength of the default
  /// algorithm: for AES this is 256 bits.
  ///
  /// [Binary] - The key as a binary, for example, a byte array.
  /// END CANONICAL DOCSTRING
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
