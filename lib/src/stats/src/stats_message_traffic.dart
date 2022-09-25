import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// MessageTraffic contains a breakdown of summary stats data
/// for traffic over various transport types
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS7
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains a breakdown of summary stats data for traffic over various
/// transport types.
/// END CANONICAL DOCSTRING
abstract class StatsMessageTraffic {
  /// BEGIN LEGACY DOCSTRING
  /// All messages count (includes realtime, rest and webhook messages).
  /// END LEGACY DOCSTRING
  StatsMessageTypes? all;

  /// BEGIN LEGACY DOCSTRING
  /// Count of messages transferred over a realtime transport
  /// such as WebSockets.
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A [Stats.MessageTypes]{@link Stats.MessageTypes} object containing a
  /// breakdown of usage by message type for messages transferred over a
  /// realtime transport such as WebSocket.
  /// END CANONICAL DOCSTRING
  StatsMessageTypes? realtime;

  /// BEGIN LEGACY DOCSTRING
  /// Count of messages transferred using REST.
  /// END LEGACY DOCSTRING
  StatsMessageTypes? rest;

  /// BEGIN LEGACY DOCSTRING
  /// Count of messages delivered using WebHooks.
  /// END LEGACY DOCSTRING
  StatsMessageTypes? webhook;
}
