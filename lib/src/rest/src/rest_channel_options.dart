import 'package:ably_flutter/ably_flutter.dart';

/// Passes additional properties to a [RestChannel] object, such as encryption,
/// [ChannelMode]and channel parameters.
class RestChannelOptions {
  /// [Channel Parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview
  /// that configure the behavior of the channel.
  final CipherParams? cipherParams;

  /// Constructor `withCipherKey`, that only takes a private [key] used to
  /// encrypt and decrypt payloads.
  static Future<RestChannelOptions> withCipherKey(dynamic key) async {
    final cipherParams = await Crypto.getDefaultParams(key: key);
    return RestChannelOptions(cipherParams: cipherParams);
  }

  /// @nodoc
  /// Create channel options with a cipher.
  /// If a [cipherParams] is set, messages will be encrypted with the cipher.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2
  RestChannelOptions({this.cipherParams});
}
