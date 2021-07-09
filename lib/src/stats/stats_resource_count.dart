/// ResourceCount contains aggregate data for usage of a resource
/// in a specific scope
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS9
abstract class StatsResourceCount {
  /// Average resources of this type used for this period.
  int? mean;

  /// Minimum total resources of this type used for this period.
  int? min;

  /// Total resources of this type opened.
  int? opened;

  /// Peak resources of this type used for this period.
  int? peak;

  /// Resource requests refused within this period.
  int? refused;
}
