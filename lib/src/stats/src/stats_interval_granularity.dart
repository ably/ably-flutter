/// BEGIN LEGACY DOCSTRING
/// https://docs.ably.com/client-lib-development-guide/features/#TS12c
/// END LEGACY DOCSTRING

/// BEGIN EDITED  CANONICAL DOCSTRING
/// Describes the interval unit over which statistics are gathered.
/// END EDITED CANONICAL DOCSTRING
enum StatsIntervalGranularity {
  /// BEGIN LEGACY DOCSTRING
  /// indicates units in minutes
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as minutes.
  /// END EDITED CANONICAL DOCSTRING
  minute,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in hours
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as hours.
  /// END EDITED CANONICAL DOCSTRING
  hour,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in days
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as days.
  /// END EDITED CANONICAL DOCSTRING
  day,

  /// BEGIN LEGACY DOCSTRING
  /// indicates units in months
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Interval unit over which statistics are gathered as months.
  /// END EDITED CANONICAL DOCSTRING
  month,
}
