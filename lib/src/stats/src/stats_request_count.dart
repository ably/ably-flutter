/// RequestCount contains aggregate counts for requests made
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS8
class StatsRequestCount {
  /// Creates instance of [StatsRequestCount]
  StatsRequestCount({this.failed, this.refused, this.succeeded});

  /// Requests failed.
  double? failed;

  /// Requests refused typically as a result of permissions
  /// or a limit being exceeded.
  double? refused;

  /// Requests succeeded.
  double? succeeded;
}
