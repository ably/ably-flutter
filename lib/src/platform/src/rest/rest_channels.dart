import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// Creates and destroys [RestChannel] objects.
class RestChannels extends Channels<RestChannel> {
  final Rest _rest;

  /// @nodoc
  /// Instantiates with the ably [Rest] instance.
  RestChannels(this._rest);

  /// @nodoc
  /// Creates a channel with provided name and options.
  ///
  /// This is a private method to be overridden by implementation classes.
  @override
  @protected
  RestChannel createChannel(String name) =>
      RestChannel(_rest, PushChannel(name, rest: _rest), name);

  /// Releases a [RestChannel] object with a specified [name], deleting it.
  ///
  /// It also removes any listeners associated with the channel. To release a
  /// channel, the [ChannelState] must be `INITIALIZED`, `DETACHED`, or
  /// `FAILED`.
  @override
  void release(String name) {
    _rest.invoke<void>(PlatformMethod.releaseRestChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
