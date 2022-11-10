/// Contains the aggregate counts for messages and data transferred.
abstract class StatsMessageCount {
  /// The count of all messages.
  int? count;

  /// The total number of bytes transferred for all messages.
  int? data;
}
