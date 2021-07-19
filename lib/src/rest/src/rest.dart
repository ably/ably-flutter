import 'package:ably_flutter/src/push_notifications/src/local_device.dart';

import '../../authentication/authentication.dart';
import '../../common/common.dart';
import 'channels.dart';

/// an abstract class for Ably's Rest client
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSC1
abstract class RestInterface<T extends RestChannelsInterface> extends AblyBase {
  /// collection of [RestChannelInterface] objects
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSN1
  late T channels;

  /// represents the current state of the device in respect of it being a
  /// target for push notifications.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH8
  Future<LocalDevice> device();

  /// https://docs.ably.com/client-lib-development-guide/features/#RSC1
  RestInterface({
    ClientOptions? options,
    final String? key,
  }) : super(
          options: options,
          key: key,
        );
}
