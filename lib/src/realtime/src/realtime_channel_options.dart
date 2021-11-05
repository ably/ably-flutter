import 'dart:typed_data';

import '../../crypto/crypto.dart';
import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../../platform/platform.dart';
import '../../rest/rest.dart';
import '../realtime.dart';

/// options provided when instantiating a realtime channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RealtimeChannelOptions extends RestChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  final CipherParams? cipher;

  /// https://docs.ably.com/client-lib-development-guide/features/#TB2c
  final Map<String, String>? params;

  /// https://docs.ably.com/client-lib-development-guide/features/#TB2d
  final List<ChannelMode>? modes;

  static Future<RealtimeChannelOptions> withCipherKey(cipherKey) async {
    if (cipherKey! is String && cipherKey! is Uint8List) {
      throw AblyException(
          'cipherKey must be a base64-encoded String or Uint8List');
    }

    final options = await Platform.methodChannel
        .invokeMethod<RealtimeChannelOptions>(
            PlatformMethod.realtimeChannelOptionsWithCipherKey, cipherKey);
    return options!;
  }

  /// create channel options with a cipher, params and modes
  /// If a [cipher] is set, messages will be encrypted with the cipher.
  RealtimeChannelOptions({this.params, this.modes, this.cipher})
      : super(cipher: cipher);
}
