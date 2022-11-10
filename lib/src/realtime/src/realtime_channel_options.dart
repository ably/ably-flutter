import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Passes additional properties to a [RealtimeChannel] object, such as
/// encryption, [ChannelMode] and channel parameters.
@immutable
class RealtimeChannelOptions {
  /// [Channel Parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview
  /// that configure the behavior of the channel.
  final CipherParams? cipherParams;

  /// [Channel Parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview)
  /// that configure the behavior of the channel.
  final Map<String, String>? params;

  /// A list of [ChannelMode] objects.
  final List<ChannelMode>? modes;

  /// Constructor `withCipherKey`, that only takes a private [key] used to
  /// encrypt and decrypt payloads.
  static Future<RealtimeChannelOptions> withCipherKey(dynamic key) async {
    final cipherParams = await Crypto.getDefaultParams(key: key);
    return RealtimeChannelOptions(cipherParams: cipherParams);
  }

  /// @nodoc
  /// create channel options with a cipher, params and modes
  /// If a [cipherParams] is set, messages will be encrypted with the cipher.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2
  const RealtimeChannelOptions({
    this.cipherParams,
    this.modes,
    this.params,
  });
}
