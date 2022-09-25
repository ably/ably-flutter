import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// A class representing an individual statistic for a specified [intervalId]
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains application statistics for a specified time interval and time
/// period.
/// END CANONICAL DOCSTRING
class Stats {
  /// BEGIN LEGACY DOCSTRING
  /// Aggregates inbound and outbound messages.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12e
  /// END LEGACY DOCSTRING
  StatsMessageTypes? all;

  /// BEGIN LEGACY DOCSTRING
  /// Breakdown of API requests received via the REST API.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12e
  /// END LEGACY DOCSTRING
  StatsRequestCount? apiRequests;

  /// BEGIN LEGACY DOCSTRING
  /// Breakdown of channels stats.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12e
  /// END LEGACY DOCSTRING
  StatsResourceCount? channels;

  /// BEGIN LEGACY DOCSTRING
  /// Breakdown of connection stats data for different (TLS vs non-TLS)
  /// connection types.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12i
  /// END LEGACY DOCSTRING
  StatsConnectionTypes? connections;

  /// BEGIN LEGACY DOCSTRING
  /// All inbound messages i.e.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12f
  /// END LEGACY DOCSTRING
  StatsMessageTraffic? inbound;

  /// BEGIN LEGACY DOCSTRING
  /// The interval that this statistic applies to,
  /// see GRANULARITY and INTERVAL_FORMAT_STRING.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12a
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The UTC time at which the time period covered begins. If unit is set to
  /// minute this will be in the format YYYY-mm-dd:HH:MM, if hour it will be
  /// YYYY-mm-dd:HH, if day it will be YYYY-mm-dd:00 and if month it will be
  /// YYYY-mm-01:00.
  /// END CANONICAL DOCSTRING
  String? intervalId;

  /// BEGIN LEGACY DOCSTRING
  /// All outbound messages i.e.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12g
  /// END LEGACY DOCSTRING
  StatsMessageTraffic? outbound;

  /// BEGIN LEGACY DOCSTRING
  /// Messages persisted for later retrieval via the history API.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12h
  /// END LEGACY DOCSTRING
  StatsMessageTypes? persisted;

  /// BEGIN LEGACY DOCSTRING
  /// Breakdown of Token requests received via the REST API.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TS12l
  /// END LEGACY DOCSTRING
  StatsRequestCount? tokenRequests;
}
