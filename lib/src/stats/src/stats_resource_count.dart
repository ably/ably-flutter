/// BEGIN LEGACY DOCSTRING
/// ResourceCount contains aggregate data for usage of a resource
/// in a specific scope
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS9
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains the aggregate data for usage of a resource in a specific scope.
/// END EDITED CANONICAL DOCSTRING
abstract class StatsResourceCount {
  /// BEGIN LEGACY DOCSTRING
  /// Average resources of this type used for this period.
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The average number of resources of this type used for this period.
  /// END EDITED CANONICAL DOCSTRING
  int? mean;

  /// BEGIN LEGACY DOCSTRING
  /// Minimum total resources of this type used for this period.
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The minimum total resources of this type used for this period.
  /// END EDITED CANONICAL DOCSTRING
  int? min;

  /// BEGIN LEGACY DOCSTRING
  /// Total resources of this type opened.
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The total number of resources opened of this type.
  /// END EDITED CANONICAL DOCSTRING
  int? opened;

  /// BEGIN LEGACY DOCSTRING
  /// Peak resources of this type used for this period.
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The peak number of resources of this type used for this period.
  /// END EDITED CANONICAL DOCSTRING
  int? peak;

  /// BEGIN LEGACY DOCSTRING
  /// Resource requests refused within this period.
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The number of resource requests refused within this period.
  /// END EDITED CANONICAL DOCSTRING
  int? refused;
}
