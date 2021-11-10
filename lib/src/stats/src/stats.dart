import 'package:ably_flutter/src/stats/src/stats_connection_types.dart';
import 'package:ably_flutter/src/stats/src/stats_message_traffic.dart';
import 'package:ably_flutter/src/stats/src/stats_message_types.dart';
import 'package:ably_flutter/src/stats/src/stats_request_count.dart';
import 'package:ably_flutter/src/stats/src/stats_resource_count.dart';

/// A class representing an individual statistic for a specified [intervalId]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS1
class Stats {
  /// Aggregates inbound and outbound messages.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12e
  StatsMessageTypes? all;

  /// Breakdown of API requests received via the REST API.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12e
  StatsRequestCount? apiRequests;

  /// Breakdown of channels stats.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12e
  StatsResourceCount? channels;

  /// Breakdown of connection stats data for different (TLS vs non-TLS)
  /// connection types.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12i
  StatsConnectionTypes? connections;

  /// All inbound messages i.e.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12f
  StatsMessageTraffic? inbound;

  /// The interval that this statistic applies to,
  /// see GRANULARITY and INTERVAL_FORMAT_STRING.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12a
  String? intervalId;

  /// All outbound messages i.e.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12g
  StatsMessageTraffic? outbound;

  /// Messages persisted for later retrieval via the history API.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12h
  StatsMessageTypes? persisted;

  /// Breakdown of Token requests received via the REST API.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12l
  StatsRequestCount? tokenRequests;
}
