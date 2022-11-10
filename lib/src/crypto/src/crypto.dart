import 'dart:convert';
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains the properties required to configure the encryption of [Message]
/// payloads.
/// END EDITED CANONICAL DOCSTRING
class Crypto {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The algorithm to use for encryption. Only `aes` is supported.
  /// END EDITED CANONICAL DOCSTRING
  static const defaultAlgorithm = 'aes';

  /// @nodoc
  /// Default length of the key in bits
  /// Equals to [keyLength256bits]
  static const defaultKeyLengthInBits = keyLength256bits;

  /// @nodoc
  /// Length of 256-bit key
  static const keyLength256bits = 256;

  /// @nodoc
  /// Length of 128-bit key
  static const keyLength128bits = 128;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The cipher mode. Only `cbc` is supported.
  /// END EDITED CANONICAL DOCSTRING
  static const defaultMode = 'cbc';

  /// BEGIN EDITED CANONICAL DOCSTRING - NEEDS DISCUSSION AND CLEARING UP
  /// Returns a [CipherParams] object, using the private [key] used to encrypt
  /// and decrypt payloads, and the default mode, key length and algorithm.
  /// END EDITED CANONICAL DOCSTRING - NEEDS DISCUSSION AND CLEARING UP
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

  /// @nodoc
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

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Generates and returns a Future with a random key as [Uint8List], to be
  /// used in the encryption of the channel, using the provided
  /// [keyLength] - the length of the key, in bits, to be generated. If not
  /// specified, this is equal to the default keyLength of the default
  /// algorithm: for AES this is 256 bits.
  /// END EDITED CANONICAL DOCSTRING
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
