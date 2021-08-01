import 'package:meta/meta.dart';

import '../../../generated/platform_constants.dart';
import '../../../rest/rest.dart';
import '../../platform.dart';
import 'rest_channel.dart';

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
