import '../../authentication/authentication.dart';

import '../../rest/rest.dart';
import '../realtime.dart';

/// options provided when instantiating a realtime channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RealtimeChannelOptions extends RestChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2c
  final Map<String, String>? params;

  /// https://docs.ably.com/client-lib-development-guide/features/#TB2d
  final List<ChannelMode>? modes;

  /// create channel options with a cipher, params and modes
  /// If a [cipher] is set, messages will be encrypted with the cipher.
  RealtimeChannelOptions({this.params, this.modes, CipherParams? cipher})
      : super(cipher: cipher);
}
