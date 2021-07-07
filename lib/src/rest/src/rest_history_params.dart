/// Params for rest history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSL2b
class RestHistoryParams {
  /// [start] must be equal to or less than end and is unaffected
  /// by the request direction
  ///
  /// RLS2b1
  final DateTime start;

  /// [end] must be equal to or greater than start and is unaffected
  /// by the request direction
  ///
  /// RLS2b1
  final DateTime end;

  /// Sorting history backwards or forwards
  ///
  /// if omitted the direction defaults to the REST API default (backwards)
  /// RLS2b2
  final String direction;

  /// Number of items returned in one page
  ///
  /// [limit] supports up to 1,000 items.
  /// if omitted the direction defaults to the REST API default (100)
  /// RLS2b3
  final int limit;

  /// instantiates with [direction] set to "backwards", [limit] to 100
  /// [start] to epoch and end to current time
  ///
  /// Raises [AssertionError] if [direction] is not "backwards" or "forwards"
  RestHistoryParams({
    DateTime? start,
    DateTime? end,
    this.direction = 'backwards',
    this.limit = 100,
  })  : assert(direction == 'backwards' || direction == 'forwards'),
        start = start ?? DateTime.fromMillisecondsSinceEpoch(0),
        end = end ?? DateTime.now();

  @override
  String toString() => 'RestHistoryParams:'
      ' start=$start'
      ' end=$end'
      ' direction=$direction'
      ' limit=$limit';
}
