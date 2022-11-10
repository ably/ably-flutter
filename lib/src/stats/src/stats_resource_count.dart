/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains the aggregate data for usage of a resource in a specific scope.
/// END EDITED CANONICAL DOCSTRING
abstract class StatsResourceCount {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The average number of resources of this type used for this period.
  /// END EDITED CANONICAL DOCSTRING
  int? mean;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The minimum total resources of this type used for this period.
  /// END EDITED CANONICAL DOCSTRING
  int? min;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The total number of resources opened of this type.
  /// END EDITED CANONICAL DOCSTRING
  int? opened;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The peak number of resources of this type used for this period.
  /// END EDITED CANONICAL DOCSTRING
  int? peak;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The number of resource requests refused within this period.
  /// END EDITED CANONICAL DOCSTRING
  int? refused;
}
