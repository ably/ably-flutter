import 'package:ably_flutter/src/common/src/history_direction.dart';
import 'package:meta/meta.dart';

/// Params for realtime history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTL10
@immutable
class RealtimeHistoryParams {
  /// [start] must be equal to or less than end and is unaffected
  /// by the request direction
  ///
  /// if omitted defaults to 1970-01-01T00:00:00Z in local timezone
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10a
  final DateTime start;

  /// [end] must be equal to or greater than start and is unaffected
  /// by the request direction
  ///
  /// if omitted defaults to current datetime in local timezone
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10a
  final DateTime end;

  /// Sorting history backwards or forwards
  ///
  /// if omitted the direction defaults to the REST API default (backwards)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10a
  final HistoryDirection direction;

  /// Number of items returned in one page
  /// [limit] supports up to 1,000 items.
  ///
  /// if omitted the direction defaults to the REST API default (100)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10a
  final int limit;

  /// Decides whether to retrieve messages from earlier session.
  ///
  /// if true, will only retrieve messages prior to the moment that the channel
  /// was attached or emitted an UPDATE indicating loss of continuity.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10b
  final bool? untilAttach;

  /// instantiates with [direction] set to [HistoryDirection.backwards],
  /// [limit] to 100, [start] to epoch and [end] to current time
  RealtimeHistoryParams({
    this.direction = HistoryDirection.backwards,
    DateTime? end,
    this.limit = 100,
    DateTime? start,
    this.untilAttach,
  })  : end = end ?? DateTime.now(),
        start = start ?? DateTime.fromMillisecondsSinceEpoch(0);

  @override
  String toString() => 'RealtimeHistoryParams:'
      ' start=$start'
      ' end=$end'
      ' direction=$direction'
      ' limit=$limit';
}
