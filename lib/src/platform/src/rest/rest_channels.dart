import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// A collection of rest channel objects
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSN1
class RestChannels extends Channels<RestChannel> {
  final Rest _rest;

  /// instantiates with the ably [Rest] instance
  RestChannels(this._rest);

  @override
  @protected
  RestChannel createChannel(String name) =>
      RestChannel(_rest, PushChannelNative(name, rest: _rest), name);

  @override
  void release(String name) {
    super.release(name);
    _rest.invoke(PlatformMethod.releaseRestChannel, name);
  }
}
