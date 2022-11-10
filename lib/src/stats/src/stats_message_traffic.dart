import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains a breakdown of summary stats data for traffic over various
/// transport types.
/// END EDITED CANONICAL DOCSTRING
abstract class StatsMessageTraffic {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for all messages (includes realtime, rest and webhook messages).
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageTypes? all;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for messages transferred over a realtime transport such as WebSocket.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageTypes? realtime;

  /// BEGIN CANONICAL DOCSTRING
  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for messages transferred over a rest transport such as WebSocket.
  /// END CANONICAL DOCSTRING
  StatsMessageTypes? rest;

  /// BEGIN CANONICAL DOCSTRING
  /// A [StatsMessageTypes] object containing a breakdown of usage by message
  /// type for messages delivered using webhooks.
  /// END CANONICAL DOCSTRING
  StatsMessageTypes? webhook;
}
