import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Configuration options for a [RealtimeChannel]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Passes additional properties to a [RestChannel]{@link RestChannel} or
/// [RealtimeChannel]{@link RealtimeChannel} object, such as encryption,
/// [ChannelMode]{@link ChannelMode} and channel parameters.
/// END CANONICAL DOCSTRING
@immutable
class RealtimeChannelOptions {
  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Requests encryption for this channel when not null, and specifies
  /// encryption-related parameters (such as algorithm, chaining mode, key
  /// length and key). See [an example](https://ably.com/docs/realtime/encryption#getting-started).
  /// END CANONICAL DOCSTRING
  final CipherParams? cipherParams;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2c
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// [Channel Parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview)
  /// that configure the behavior of the channel.
  /// END CANONICAL DOCSTRING
  final Map<String, String>? params;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2d
  /// END LEGACY DOCSTRING
  final List<ChannelMode>? modes;

  /// BEGIN LEGACY DOCSTRING
  /// Create a [RealtimeChannelOptions] directly from a CipherKey. This is a
  /// convenience method you can use if you don't need to specify
  /// other parameters of [RealtimeChannelOptions].
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TB3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Constructor withCipherKey, that takes a key only.
  ///
  /// [key] - A private key used to encrypt and decrypt payloads.
  ///
  /// [ChannelOptions] - A ChannelOptions object.
  /// END CANONICAL DOCSTRING
  static Future<RealtimeChannelOptions> withCipherKey(dynamic key) async {
    final cipherParams = await Crypto.getDefaultParams(key: key);
    return RealtimeChannelOptions(cipherParams: cipherParams);
  }

  /// BEGIN LEGACY DOCSTRING
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
