import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// A collection of realtime channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTS1
/// END LEGACY DOCSTRING
class RealtimeChannels extends Channels<RealtimeChannel> {
  /// BEGIN LEGACY DOCSTRING
  /// instance of ably realtime client
  /// END LEGACY DOCSTRING
  Realtime realtime;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates with the ably [Realtime] instance
  /// END LEGACY DOCSTRING
  RealtimeChannels(this.realtime);

  @override
  @protected
  RealtimeChannel createChannel(String name) => RealtimeChannel(realtime, name);

  /// BEGIN LEGACY DOCSTRING
  /// Detaches the channel and then releases the channel resource
  /// so it can be garbage collected.
  /// END LEGACY DOCSTRING
  @override
  void release(String name) {
    realtime.invoke<void>(PlatformMethod.releaseRealtimeChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
