/// BEGIN LEGACY DOCSTRING
/// MessageCount contains aggregate counts for messages and data transferred
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS5
/// END LEGACY DOCSTRING
abstract class StatsMessageCount {
  /// BEGIN LEGACY DOCSTRING
  /// Count of all messages.
  /// END LEGACY DOCSTRING
  int? count;

  /// BEGIN LEGACY DOCSTRING
  /// Total data transferred for all messages in bytes.
  /// END LEGACY DOCSTRING
  int? data;
}
