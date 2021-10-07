/// params to configure encryption for a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TZ1
class CipherParams {
  /// Specifies the algorithm to use for encryption
  ///
  /// Default is AES. Currently only AES is supported.
  /// https://docs.ably.com/client-lib-development-guide/features/#TZ2a
  String? algorithm;

  /// private key used to encrypt and decrypt payloads
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TZ2d
  dynamic key;

  /// the length in bits of the key
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TZ2b
  int? keyLength;

  /// Specify cipher mode
  ///
  /// Default is CBC. Currently only CBC is supported
  /// https://docs.ably.com/client-lib-development-guide/features/#TZ2c
  String? mode;

  CipherParams({this.algorithm, this.key, this.keyLength, this.mode});
}
