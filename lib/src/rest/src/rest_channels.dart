import '../../common/common.dart';
import '../rest.dart';

/// A collection of REST channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSN1
abstract class RestChannelsInterface<T extends RestChannelInterface>
    extends Channels<T> {
  /// instance of a rest client
  RestInterface rest;

  /// instantiates with the ably [RestInterface] instance
  RestChannelsInterface(this.rest);
}
