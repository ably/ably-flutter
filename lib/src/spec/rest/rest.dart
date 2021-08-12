import '../rest/ably_base.dart';
import '../rest/options.dart';
import 'ably_base.dart';
import 'channels.dart';
import 'options.dart';

/// an abstract class for Ably's Rest client
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSC1
abstract class RestInterface<C extends RestChannels> extends AblyBase {
  /// collection of [RestChannelInterface] objects
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSN1
  late C channels;

  /// https://docs.ably.com/client-lib-development-guide/features/#RSC1
  RestInterface({
    ClientOptions? options,
    final String? key,
  }) : super(
          options: options,
          key: key,
        );
}
