import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Creates and destroys [RealtimeChannel] objects.
/// END EDITED CANONICAL DOCSTRING
class RealtimeChannels extends Channels<RealtimeChannel> {
  /// @nodoc
  /// instance of ably realtime client
  Realtime realtime;

  /// @nodoc
  /// instantiates with the ably [Realtime] instance
  RealtimeChannels(this.realtime);

  @override
  @protected
  RealtimeChannel createChannel(String name) => RealtimeChannel(realtime, name);

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Releases a [RealtimeChannel] object with a specified [name], deleting it.
  /// It also removes any listeners associated with the channel. To release a
  /// channel, the [ChannelState] must be `INITIALIZED`, `DETACHED`, or `FAILED`f.
  /// END EDITED CANONICAL DOCSTRING
  @override
  void release(String name) {
    realtime.invoke<void>(PlatformMethod.releaseRealtimeChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
