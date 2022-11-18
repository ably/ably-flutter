import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// Creates and destroys [RealtimeChannel] objects.
class RealtimeChannels extends Channels<RealtimeChannel> {
  /// @nodoc
  /// instance of ably realtime client
  Realtime realtime;

  /// @nodoc
  /// instantiates with the ably [Realtime] instance
  RealtimeChannels(this.realtime);

  /// @nodoc
  @override
  @protected
  RealtimeChannel createChannel(String name) => RealtimeChannel(realtime, name);

  /// Releases a [RealtimeChannel] object with a specified [name], deleting it.
  ///
  /// It also removes any listeners associated with the channel. To release a
  /// channel, the [ChannelState] must be `INITIALIZED`, `DETACHED`, or
  /// `FAILED`.
  @override
  void release(String name) {
    realtime.invoke<void>(PlatformMethod.releaseRealtimeChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
