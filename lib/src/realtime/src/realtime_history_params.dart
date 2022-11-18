import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Contains properties used to filter [RealtimeChannel] history.
@immutable
class RealtimeHistoryParams {
  /// The [DateTime] from which messages are retrieved.
  final DateTime start;

  /// The [DateTime] until messages are retrieved.
  final DateTime end;

  /// The order for which messages are returned in.
  ///
  /// Valid values are `backwards` which orders messages from most recent to
  /// oldest, or `forwards` which orders messages from oldest to most recent.
  /// The default is `backwards`.
  final String direction;

  /// An upper limit on the number of messages returned. The default is 100, and
  /// the maximum is 1000.
  final int limit;

  /// Whether it's ensured that the message history is up until the point
  /// of the channel being attached.
  ///
  /// See [continuous history](https://ably.com/docs/realtime/history#continuous-history)
  /// for more info. Requires the direction to be `backwards`. If the channel is
  /// not attached, or if `direction` is set to `forwards`, this option results
  /// in an error.
  final bool? untilAttach;

  /// @nodoc
  /// instantiates with [direction] set to "backwards", [limit] to 100
  /// [start] to epoch and end to current time
  ///
  /// Raises [AssertionError] if [direction] is not "backwards" or "forwards"
  RealtimeHistoryParams({
    this.direction = 'backwards',
    DateTime? end,
    this.limit = 100,
    DateTime? start,
    this.untilAttach,
  })  : assert(direction == 'backwards' || direction == 'forwards'),
        end = end ?? DateTime.now(),
        start = start ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String toString() => 'RealtimeHistoryParams:'
      ' start=$start'
      ' end=$end'
      ' direction=$direction'
      ' limit=$limit';
}
