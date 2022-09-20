/// BEGIN LEGACY DOCSTRING
/// RequestCount contains aggregate counts for requests made
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS8
/// END LEGACY DOCSTRING
abstract class StatsRequestCount {
  /// BEGIN LEGACY DOCSTRING
  /// Requests failed.
  /// END LEGACY DOCSTRING
  int? failed;

  /// BEGIN LEGACY DOCSTRING
  /// Requests refused typically as a result of permissions
  /// or a limit being exceeded.
  /// END LEGACY DOCSTRING
  int? refused;

  /// BEGIN LEGACY DOCSTRING
  /// Requests succeeded.
  /// END LEGACY DOCSTRING
  int? succeeded;
}
