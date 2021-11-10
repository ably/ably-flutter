import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// A collection of realtime channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTS1
class RealtimeChannels extends Channels<RealtimeChannel> {
  /// instance of ably realtime client
  Realtime realtime;

  /// instantiates with the ably [Realtime] instance
  RealtimeChannels(this.realtime);

  @override
  @protected
  RealtimeChannel createChannel(String name) => RealtimeChannel(realtime, name);

  void release(String name) {
    realtime.invoke(PlatformMethod.releaseRealtimeChannel, name);
  }
}
