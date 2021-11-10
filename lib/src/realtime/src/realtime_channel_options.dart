import 'package:ably_flutter/ably_flutter.dart';

/// Configuration options for a [RealtimeChannel]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RealtimeChannelOptions extends RestChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  @override
  final CipherParams? cipherParams;

  /// https://docs.ably.com/client-lib-development-guide/features/#TB2c
  final Map<String, String>? params;

  /// https://docs.ably.com/client-lib-development-guide/features/#TB2d
  final List<ChannelMode>? modes;

  /// Create a [RealtimeChannelOptions] directly from a CipherKey. This is a
  /// convenience method you can use if you don't need to specify
  /// other parameters of [RealtimeChannelOptions].
  static Future<RealtimeChannelOptions> withCipherKey(key) async {
    final cipherParams = await Crypto.getDefaultParams(key: key);
    return RealtimeChannelOptions(cipherParams: cipherParams);
  }

  /// create channel options with a cipher, params and modes
  /// If a [cipherParams] is set, messages will be encrypted with the cipher.
  RealtimeChannelOptions({this.params, this.modes, this.cipherParams})
      : super(cipherParams: cipherParams);
}
