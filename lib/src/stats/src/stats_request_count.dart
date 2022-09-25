/// BEGIN LEGACY DOCSTRING
/// RequestCount contains aggregate counts for requests made
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS8
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains the aggregate counts for requests made.
/// END CANONICAL DOCSTRING
abstract class StatsRequestCount {
  /// BEGIN LEGACY DOCSTRING
  /// Requests failed.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The number of requests that failed.
  /// END CANONICAL DOCSTRING
  int? failed;

  /// BEGIN LEGACY DOCSTRING
  /// Requests refused typically as a result of permissions
  /// or a limit being exceeded.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The number of requests that were refused, typically as a result of
  /// permissions or a limit being exceeded.
  /// END CANONICAL DOCSTRING
  int? refused;

  /// BEGIN LEGACY DOCSTRING
  /// Requests succeeded.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The number of requests that succeeded.
  /// END CANONICAL DOCSTRING
  int? succeeded;
}
