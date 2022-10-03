import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Configuration options for a [RestChannel]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Passes additional properties to a [RestChannel] object, such as encryption,
/// [ChannelMode]and channel parameters.
/// END CANONICAL DOCSTRING
class RestChannelOptions {
  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// [Channel Parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview
  /// that configure the behavior of the channel.
  /// END EDITED CANONICAL DOCSTRING
  final CipherParams? cipherParams;

  /// BEGIN LEGACY DOCSTRING
  /// Create a [RestChannelOptions] directly from a CipherKey. This is
  /// equivalent to calling the constructor.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TB3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Constructor `withCipherKey`, that onnly takes a private [key] used to
  /// encrypt and decrypt payloads.
  /// END CANONICAL DOCSTRING
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
