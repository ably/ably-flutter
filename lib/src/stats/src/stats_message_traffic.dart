import 'package:ably_flutter/ably_flutter.dart';

/// Contains a breakdown of summary stats data for traffic over various
/// transport types.
abstract class StatsMessageTraffic {
  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for all messages (includes realtime, rest and webhook messages).
  StatsMessageTypes? all;

  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for messages transferred over a realtime transport such as WebSocket.
  StatsMessageTypes? realtime;

  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for messages transferred over a rest transport such as WebSocket.
  StatsMessageTypes? rest;

  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for messages delivered using webhooks.
  StatsMessageTypes? webhook;
}
