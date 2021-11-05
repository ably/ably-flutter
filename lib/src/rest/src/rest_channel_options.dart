import 'dart:typed_data';

import '../../crypto/crypto.dart';
import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../../platform/platform.dart';

/// options provided when instantiating a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RestChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  final CipherParams? cipher;

  static Future<RestChannelOptions> withCipherKey(cipherKey) async {
    if (cipherKey! is String && cipherKey! is Uint8List) {
      throw AblyException('cipherKey must be a String or Uint8List');
    }

    final options = await Platform.methodChannel
        .invokeMethod<RestChannelOptions>(
            PlatformMethod.channelOptionsWithCipherKey, cipherKey);
    return options!;
  }

  /// create channel options with a cipher.
  /// If a [cipher] is set, messages will be encrypted with the cipher.
  RestChannelOptions({this.cipher});
}
