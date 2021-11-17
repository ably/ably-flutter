import 'package:ably_flutter/ably_flutter.dart';

/// Configuration options for a [RestChannel]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RestChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  final CipherParams? cipherParams;

  /// Create a [RestChannelOptions] directly from a CipherKey. This is
  /// equivalent to calling the constructor.
  static Future<RestChannelOptions> withCipherKey(key) async {
    final cipherParams = await Crypto.getDefaultParams(key: key);
    return RestChannelOptions(cipherParams: cipherParams);
  }

  /// Create channel options with a cipher.
  /// If a [cipherParams] is set, messages will be encrypted with the cipher.
  RestChannelOptions({this.cipherParams});
}
