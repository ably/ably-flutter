/// BEGIN LEGACY DOCSTRING
/// Params for rest history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSL2b
/// END LEGACY DOCSTRING
class RestHistoryParams {
  /// BEGIN LEGACY DOCSTRING
  /// [start] must be equal to or less than end and is unaffected
  /// by the request direction
  ///
  /// if omitted defaults to 1970-01-01T00:00:00Z in local timezone
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2b1
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRINGS
  /// The [DateTime] from which messages are retrieved.
  /// END CANONICAL DOCSTRINGS
  final DateTime start;

  /// BEGIN LEGACY DOCSTRING
  /// [end] must be equal to or greater than start and is unaffected
  /// by the request direction
  ///
  /// if omitted defaults to current datetime in local timezone
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2b1
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRINGS
  /// The [DateTime] until messages are retrieved.
  /// END EDITED CANONICAL DOCSTRINGS
  final DateTime end;

  /// BEGIN LEGACY DOCSTRING
  /// Sorting history backwards or forwards
  ///
  /// if omitted the direction defaults to the REST API default (backwards)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2b2
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRINGS
  /// The order for which messages are returned in. Valid values are `backwards`
  /// which orders messages from most recent to oldest, or `forwards` which
  /// orders messages from oldest to most recent. The default is `backwards`.
  /// END EDITED CANONICAL DOCSTRINGS
  final String direction;

  /// BEGIN LEGACY DOCSTRING
  /// Number of items returned in one page
  /// [limit] supports up to 1,000 items.
  ///
  /// if omitted the direction defaults to the REST API default (100)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2b3
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRINGS
  /// An upper limit on the number of messages returned. The default
  /// is 100, and the maximum is 1000.
  /// END EDITED CANONICAL DOCSTRINGS
  final int limit;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates with [direction] set to "backwards", [limit] to 100
  /// [start] to epoch and end to current time
  ///
  /// Raises [AssertionError] if [direction] is not "backwards" or "forwards"
  /// END LEGACY DOCSTRING
  RestHistoryParams({
    this.direction = 'backwards',
    DateTime? end,
    this.limit = 100,
    DateTime? start,
  })  : assert(direction == 'backwards' || direction == 'forwards'),
        end = end ?? DateTime.now(),
        start = start ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String toString() => 'RestHistoryParams:'
      ' start=$start'
      ' end=$end'
      ' direction=$direction'
      ' limit=$limit';
}
