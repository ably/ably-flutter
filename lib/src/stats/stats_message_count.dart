/// MessageCount contains aggregate counts for messages and data transferred
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS5
abstract class StatsMessageCount {
  /// Count of all messages.
  int? count;

  /// Total data transferred for all messages in bytes.
  int? data;
}