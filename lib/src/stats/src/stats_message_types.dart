import 'package:ably_flutter/ably_flutter.dart';

/// Contains a breakdown of summary stats data for different
/// (channel vs presence) message types.
abstract class StatsMessageTypes {
  /// A [StatsMessageCount]object containing the count and byte value of
  /// messages and presence messages.
  StatsMessageCount? all;

  /// A [StatsMessageCount] object containing the count and byte value of
  /// messages.
  StatsMessageCount? messages;

  /// A [StatsMessageCount] object containing the count and byte value of
  /// presence messages.
  StatsMessageCount? presence;
}
