/// Contains the aggregate data for usage of a resource in a specific scope.
abstract class StatsResourceCount {
  /// The average number of resources of this type used for this period.
  int? mean;

  /// The minimum total resources of this type used for this period.
  int? min;

  /// The total number of resources opened of this type.
  int? opened;

  /// The peak number of resources of this type used for this period.
  int? peak;

  /// The number of resource requests refused within this period.
  int? refused;
}
