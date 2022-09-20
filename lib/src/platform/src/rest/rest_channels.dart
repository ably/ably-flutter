import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// A collection of rest channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSN1
/// END LEGACY DOCSTRING
class RestChannels extends Channels<RestChannel> {
  final Rest _rest;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates with the ably [Rest] instance
  /// END LEGACY DOCSTRING
  RestChannels(this._rest);

  @override
  @protected
  RestChannel createChannel(String name) =>
      RestChannel(_rest, PushChannel(name, rest: _rest), name);

  @override
  void release(String name) {
    _rest.invoke<void>(PlatformMethod.releaseRestChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
