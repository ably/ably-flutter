import 'package:ably_flutter/src/generated/platform_constants.dart';
import 'package:ably_flutter/src/platform/platform.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:ably_flutter/src/rest/src/rest_channels.dart';
import 'package:meta/meta.dart';

/// A collection of rest channel objects
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSN1
class RestChannels extends RestChannelsInterface<RestChannel> {
  /// instantiates with the ably [Rest] instance
  RestChannels(Rest rest) : super(rest);

  @override
  @protected
  RestChannel createChannel(String name) =>
      RestChannel(rest, PushChannelNative(name, rest: rest), name);

  @override
  void release(String name) {
    super.release(name);
    (rest as Rest).invoke(PlatformMethod.releaseRestChannel, name);
  }
}
