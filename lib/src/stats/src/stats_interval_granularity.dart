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

  /// BEGIN CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as minutes.
  /// END CANONICAL DOCSTRING
  minute,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in hours
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as hours.
  /// END CANONICAL DOCSTRING
  hour,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in days
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as days.
  /// END CANONICAL DOCSTRING
  day,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in months
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as months.
  /// END CANONICAL DOCSTRING
  month,
}
