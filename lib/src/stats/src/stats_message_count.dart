/// BEGIN LEGACY DOCSTRING
/// MessageCount contains aggregate counts for messages and data transferred
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS5
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains the aggregate counts for messages and data transferred.
/// END CANONICAL DOCSTRING
abstract class StatsMessageCount {
  /// BEGIN LEGACY DOCSTRING
  /// Count of all messages.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The count of all messages.
  /// END CANONICAL DOCSTRING
  int? count;

  /// BEGIN LEGACY DOCSTRING
  /// Total data transferred for all messages in bytes.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The total number of bytes transferred for all messages.
  /// END CANONICAL DOCSTRING
  int? data;
}
