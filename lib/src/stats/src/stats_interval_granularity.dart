/// BEGIN LEGACY DOCSTRING
/// https://docs.ably.com/client-lib-development-guide/features/#TS12c
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Describes the interval unit over which statistics are gathered.
/// END CANONICAL DOCSTRING
enum StatsIntervalGranularity {
  /// BEGIN LEGACY DOCSTRING
  /// indicates units in minutes
  /// END LEGACY DOCSTRING
  minute,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in hours
  /// END LEGACY DOCSTRING
  hour,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in days
  /// END LEGACY DOCSTRING
  day,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in months
  /// END LEGACY DOCSTRING
  month,
}
