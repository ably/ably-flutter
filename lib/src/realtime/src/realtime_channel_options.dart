import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN CANONICAL DOCSTRING
/// Passes additional properties to a [RealtimeChannel] object, such as
/// encryption, [ChannelMode] and channel parameters.
/// END CANONICAL DOCSTRING
@immutable
class RealtimeChannelOptions {

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// [Channel Parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview
  /// that configure the behavior of the channel.
  /// END EDITED CANONICAL DOCSTRING
  final CipherParams? cipherParams;

  /// BEGIN CANONICAL DOCSTRING
  /// [Channel Parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview)
  /// that configure the behavior of the channel.
  /// END CANONICAL DOCSTRING
  final Map<String, String>? params;

  /// BEGIN CANONICAL DOCSTRING
  /// A list of [ChannelMode] objects.
  /// END CANONICAL DOCSTRING
  final List<ChannelMode>? modes;

  /// BEGIN CANONICAL DOCSTRING
  /// Constructor `withCipherKey`, that only takes a private [key] used to
  /// encrypt and decrypt payloads.
  /// END CANONICAL DOCSTRING
  static Future<RealtimeChannelOptions> withCipherKey(dynamic key) async {
    final cipherParams = await Crypto.getDefaultParams(key: key);
    return RealtimeChannelOptions(cipherParams: cipherParams);
  }

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// create channel options with a cipher, params and modes
  /// If a [cipherParams] is set, messages will be encrypted with the cipher.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2
  /// END LEGACY DOCSTRING
  const RealtimeChannelOptions({
    this.cipherParams,
    this.modes,
    this.params,
  });
}
