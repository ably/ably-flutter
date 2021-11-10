import 'package:ably_flutter/ably_flutter.dart';

/// Presence object on a [RestChannel] helps to query Presence members
/// and presence history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSP1
abstract class RestPresenceInterface {
  /// Obtain the set of members currently present for a channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3
  Future<PaginatedResultInterface<PresenceMessage>> get([
    RestPresenceParams? params,
  ]);

  /// Return the presence messages history for the channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP4
  Future<PaginatedResultInterface<PresenceMessage>> history([
    RestHistoryParams? params,
  ]);
}
