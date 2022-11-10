/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains the aggregate counts for requests made.
/// END EDITED CANONICAL DOCSTRING
abstract class StatsRequestCount {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The number of requests that failed.
  /// ENDE EDITED CANONICAL DOCSTRING
  int? failed;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The number of requests that were refused, typically as a result of
  /// permissions or a limit being exceeded.
  /// END EDITED CANONICAL DOCSTRING
  int? refused;
  
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The number of requests that succeeded.
  /// END EDITED CANONICAL DOCSTRING
  int? succeeded;
}
