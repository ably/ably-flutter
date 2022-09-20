import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Configuration options for a [RestChannel]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
/// END LEGACY DOCSTRING
class RestChannelOptions {
  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  /// END LEGACY DOCSTRING
  final CipherParams? cipherParams;

  /// BEGIN LEGACY DOCSTRING
  /// Create a [RestChannelOptions] directly from a CipherKey. This is
  /// equivalent to calling the constructor.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TB3
  /// END LEGACY DOCSTRING
  static Future<RestChannelOptions> withCipherKey(dynamic key) async {
    final cipherParams = await Crypto.getDefaultParams(key: key);
    return RestChannelOptions(cipherParams: cipherParams);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Create channel options with a cipher.
  /// If a [cipherParams] is set, messages will be encrypted with the cipher.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2
  /// END LEGACY DOCSTRING
  RestChannelOptions({this.cipherParams});
}
