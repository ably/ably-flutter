import 'package:ably_flutter/ably_flutter.dart';

/// MessageTypes contains a breakdown of summary stats data
/// for different (message vs presence) message types
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS6
class StatsMessageTypes {
  /// Creates instance of [StatsMessageTypes]
  StatsMessageTypes({this.all, this.messages, this.presence});

  /// All messages count (includes both presence & messages).
  StatsMessageCount? all;

  /// Count of channel messages.
  StatsMessageCount? messages;

  /// Count of presence messages.
  StatsMessageCount? presence;
}
