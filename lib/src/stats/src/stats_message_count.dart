/// BEGIN CANONICAL DOCSTRING
/// Contains the aggregate counts for messages and data transferred.
/// END CANONICAL DOCSTRING
abstract class StatsMessageCount {
  /// BEGIN CANONICAL DOCSTRING
  /// The count of all messages.
  /// END CANONICAL DOCSTRING
  int? count;

  /// BEGIN CANONICAL DOCSTRING
  /// The total number of bytes transferred for all messages.
  /// END CANONICAL DOCSTRING
  int? data;
}
