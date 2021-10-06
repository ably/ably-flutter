import '../../rest/src/channel_options.dart';
import 'channel_mode.dart';

/// options provided when instantiating a realtime channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RealtimeChannelOptions extends ChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2c
  final Map<String, String>? params;

  /// https://docs.ably.com/client-lib-development-guide/features/#TB2d
  final List<ChannelMode>? modes;

  /// create channel options with a cipher, params and modes
  RealtimeChannelOptions({this.params, this.modes, Object? cipher})
      : super(cipher: cipher);
}