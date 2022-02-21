import 'package:ably_flutter/ably_flutter.dart';

/// MessageTraffic contains a breakdown of summary stats data
/// for traffic over various transport types
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS7
class StatsMessageTraffic {
  /// Creates instance of [StatsMessageTraffic]
  StatsMessageTraffic({this.all, this.realtime, this.rest, this.webhook});

  /// All messages count (includes realtime, rest and webhook messages).
  StatsMessageTypes? all;

  /// Count of messages transferred over a realtime transport
  /// such as WebSockets.
  StatsMessageTypes? realtime;

  /// Count of messages transferred using REST.
  StatsMessageTypes? rest;

  /// Count of messages delivered using WebHooks.
  StatsMessageTypes? webhook;
}
