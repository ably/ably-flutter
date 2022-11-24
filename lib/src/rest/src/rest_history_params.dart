import 'package:ably_flutter/ably_flutter.dart';

/// Contains properties used to filter [RestChannel] history.
class RestHistoryParams {
  /// The [DateTime] from which messages are retrieved.
  final DateTime start;

  /// The [DateTime] until messages are retrieved.
  final DateTime end;

  /// The order for which messages are returned in. Valid values are `backwards`
  /// which orders messages from most recent to oldest, or `forwards` which
  /// orders messages from oldest to most recent.
  ///
  /// The default is `backwards`.
  final String direction;

  /// An upper limit on the number of messages returned.
  ///
  /// The default is 100, and the maximum is 1000.
  final int limit;

  /// @nodoc
  /// instantiates with [direction] set to "backwards", [limit] to 100
  /// [start] to epoch and end to current time
  ///
  /// Raises [AssertionError] if [direction] is not "backwards" or "forwards"
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
