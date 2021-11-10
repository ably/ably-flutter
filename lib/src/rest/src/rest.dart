import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/rest/src/rest_channels.dart';

/// an abstract class for Ably's Rest client
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSC1
abstract class RestInterface<T extends RestChannelsInterface> extends AblyBase {
  /// collection of [RestChannelInterface] objects
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSN1
  late T channels;

  /// https://docs.ably.com/client-lib-development-guide/features/#RSC1
  RestInterface({
    ClientOptions? options,
    final String? key,
  }) : super(
          options: options,
          key: key,
        );
}
