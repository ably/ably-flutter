/// Params used as a filter for querying presence on a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSP3a
class RestPresenceParams {
  /// number of records to fetch per page
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3a1
  int limit;

  /// filters members by the provided clientId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3a2
  String? clientId;

  /// filters members by the provided connectionId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3a3
  String? connectionId;

  /// initializes with default [limit] set to 100
  RestPresenceParams({
    this.clientId,
    this.connectionId,
    this.limit = 100,
  });
}
