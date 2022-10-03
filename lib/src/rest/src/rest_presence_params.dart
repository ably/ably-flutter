/// BEGIN LEGACY DOCSTRING
/// Params used as a filter for querying presence on a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSP3a
/// END LEGACY DOCSTRING
class RestPresenceParams {
  /// BEGIN LEGACY DOCSTRING
  /// number of records to fetch per page
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3a1
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An upper limit on the number of messages returned. The default is 100, and
  /// the maximum is 1000.
  /// END EDITED CANONICAL DOCSTRING
  int limit;

  /// BEGIN LEGACY DOCSTRING
  /// filters members by the provided clientId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3a2
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Filters the list of returned presence members by a specific client using
  /// its ID.
  /// END EDITED CANONICAL DOCSTRING
  String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// filters members by the provided connectionId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSP3a3
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Filters the list of returned presence members by a specific connection
  /// using its ID.
  /// END EDITED CANONICAL DOCSTRING
  String? connectionId;

  /// BEGIN LEGACY DOCSTRING
  /// initializes with default [limit] set to 100
  /// END LEGACY DOCSTRING
  RestPresenceParams({
    this.clientId,
    this.connectionId,
    this.limit = 100,
  });
}
