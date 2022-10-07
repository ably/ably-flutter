import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// A collection of rest channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSN1
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Creates and destroys [RestChannel] objects.
/// END EDITED CANONICAL DOCSTRING
class RestChannels extends Channels<RestChannel> {
  final Rest _rest;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates with the ably [Rest] instance
  /// END LEGACY DOCSTRING
  RestChannels(this._rest);

  /// BEGIN LEGACY DOCSTRING
  /// creates a channel with provided name and options
  ///
  /// This is a private method to be overridden by implementation classes
  /// END LEGACY DOCSTRING
  @override
  @protected
  RestChannel createChannel(String name) =>
      RestChannel(_rest, PushChannel(name, rest: _rest), name);

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Releases a [RestChannel] object with a specified [name], deleting it. It
  /// also removes any listeners associated with the channel. To release a
  /// channel, the [ChannelState] must be `INITIALIZED`, `DETACHED`, or
  /// `FAILED`.
  /// END EDITED CANONICAL DOCSTRING
  @override
  void release(String name) {
    _rest.invoke<void>(PlatformMethod.releaseRestChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
