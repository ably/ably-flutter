/// Contains the aggregate counts for requests made.
abstract class StatsRequestCount {
  /// The number of requests that failed.
  int? failed;

  /// The number of requests that were refused, typically as a result of
  /// permissions or a limit being exceeded.
  int? refused;

  /// The number of requests that succeeded.
  int? succeeded;
}
