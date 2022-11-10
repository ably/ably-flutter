import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRINGS
/// Contains properties used to filter [RestChannel] history.
/// END EDITED CANONICAL DOCSTRINGS
class RestHistoryParams {
  /// BEGIN CANONICAL DOCSTRINGS
  /// The [DateTime] from which messages are retrieved.
  /// END CANONICAL DOCSTRINGS
  final DateTime start;

  /// BEGIN EDITED CANONICAL DOCSTRINGS
  /// The [DateTime] until messages are retrieved.
  /// END EDITED CANONICAL DOCSTRINGS
  final DateTime end;

  /// BEGIN EDITED CANONICAL DOCSTRINGS
  /// The order for which messages are returned in. Valid values are `backwards`
  /// which orders messages from most recent to oldest, or `forwards` which
  /// orders messages from oldest to most recent. The default is `backwards`.
  /// END EDITED CANONICAL DOCSTRINGS
  final String direction;

  /// BEGIN EDITED CANONICAL DOCSTRINGS
  /// An upper limit on the number of messages returned. The default
  /// is 100, and the maximum is 1000.
  /// END EDITED CANONICAL DOCSTRINGS
  final int limit;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
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
