/// RequestCount contains aggregate counts for requests made
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS8
abstract class StatsRequestCount {
  /// Requests failed.
  int? failed;

  /// Requests refused typically as a result of permissions
  /// or a limit being exceeded.
  int? refused;

  /// Requests succeeded.
  int? succeeded;
}
