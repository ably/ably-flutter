/// ResourceCount contains aggregate data for usage of a resource
/// in a specific scope
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS9
class StatsResourceCount {
  /// Creates instance of [StatsResourceCount]
  StatsResourceCount(
      {this.mean, this.min, this.opened, this.peak, this.refused});

  /// Average resources of this type used for this period.
  double? mean;

  /// Minimum total resources of this type used for this period.
  double? min;

  /// Total resources of this type opened.
  double? opened;

  /// Peak resources of this type used for this period.
  double? peak;

  /// Resource requests refused within this period.
  double? refused;
}
