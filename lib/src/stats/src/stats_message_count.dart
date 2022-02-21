/// MessageCount contains aggregate counts for messages and data transferred
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS5
class StatsMessageCount {
  ///Creates instance of [StatsMessageCount]
  StatsMessageCount({this.count, this.data});

  /// Count of all messages.
  double? count;

  /// Total data transferred for all messages in bytes.
  double? data;
}
