import 'package:ably_flutter/ably_flutter.dart';

/// Contains application statistics for a specified time interval and time
/// period.
class Stats {
  /// A [StatsMessageTypes] object containing the  aggregate count of all
  /// message stats.
  StatsMessageTypes? all;

  /// A [StatsRequestCount] object containing a breakdown of API Requests.
  StatsRequestCount? apiRequests;

  /// A [StatsResourceCount] object containing a breakdown of channels.
  StatsResourceCount? channels;

  /// A [StatsConnectionTypes] object containing a breakdown of connection
  /// related stats, such as min, mean and peak connections.
  StatsConnectionTypes? connections;

  /// A [StatsMessageTraffic] object containing the aggregate count of inbound
  /// message stats.
  StatsMessageTraffic? inbound;

  /// The UTC time at which the time period covered begins.
  ///
  /// If `unit` is set to `minute` this will be in the format
  /// `YYYY-mm-dd:HH:MM`, if `hour` it will be `YYYY-mm-dd:HH`, if day it will
  /// be `YYYY-mm-dd:00` and if `month` it will be `YYYY-mm-01:00`.
  String? intervalId;

  /// A [StatsMessageTraffic] object containing the aggregate count of outbound
  /// message stats.
  StatsMessageTraffic? outbound;

  /// A [StatsMessageTypes] object containing the aggregate count of persisted
  /// message stats.
  StatsMessageTypes? persisted;

  /// A [StatsRequestCount] object containing a breakdown of Ably Token
  /// requests.
  StatsRequestCount? tokenRequests;
}
