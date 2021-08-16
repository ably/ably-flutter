// TODO stop extending RestHistoryParams:
//  RealtimeHistoryParams is not a RestHistoryParams
import '../../rest/rest.dart';

/// https://docs.ably.com/client-lib-development-guide/features/#RTL10
class RealtimeHistoryParams extends RestHistoryParams {
  /// Decides whether to retrieve messages from earlier session.
  ///
  /// if true, will only retrieve messages prior to the moment that the channel
  /// was attached or emitted an UPDATE indicating loss of continuity.
  bool? untilAttach;

  /// instantiates with [direction] set to "backwards", [limit] to 100
  /// [start] to epoch and end to current time
  ///
  /// Raises [AssertionError] if [direction] is not "backwards" or "forwards"
  RealtimeHistoryParams({
    DateTime? start,
    DateTime? end,
    String direction = 'backwards',
    int limit = 100,
    this.untilAttach,
  }) : super(
          start: start,
          end: end,
          direction: direction,
          limit: limit,
        );
}
