import 'stats_message_count.dart';

/// MessageTypes contains a breakdown of summary stats data
/// for different (message vs presence) message types
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS6
abstract class StatsMessageTypes {
  /// All messages count (includes both presence & messages).
  StatsMessageCount? all;

  /// Count of channel messages.
  StatsMessageCount? messages;

  /// Count of presence messages.
  StatsMessageCount? presence;
}
