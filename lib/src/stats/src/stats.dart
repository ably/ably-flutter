import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains application statistics for a specified time interval and time
/// period.
/// END EDITED CANONICAL DOCSTRING
class Stats {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageTypes] object containing the  aggregate count of all
  /// message stats.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageTypes? all;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsRequestCount] object containing a breakdown of API Requests.
  /// END EDITED CANONICAL DOCSTRING
  StatsRequestCount? apiRequests;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsResourceCount] object containing a breakdown of channels.
  /// END EDITED CANONICAL DOCSTRING
  StatsResourceCount? channels;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsConnectionTypes] object containing a breakdown of connection
  /// related stats, such as min, mean and peak connections.
  /// END EDITED CANONICAL DOCSTRING
  StatsConnectionTypes? connections;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageTraffic] object containing the aggregate count of inbound
  /// message stats.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageTraffic? inbound;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The UTC time at which the time period covered begins. If `unit` is set to
  /// `minute` this will be in the format `YYYY-mm-dd:HH:MM`, if `hour` it will
  /// be `YYYY-mm-dd:HH`, if day it will be `YYYY-mm-dd:00` and if `month` it
  /// will be `YYYY-mm-01:00`.
  /// END EDITED CANONICAL DOCSTRING
  String? intervalId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageTraffic] object containing the aggregate count of outbound
  /// message stats.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageTraffic? outbound;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageTypes] object containing the aggregate count of persisted
  /// message stats.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageTypes? persisted;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsRequestCount] object containing a breakdown of Ably Token
  /// requests.
  /// END EDITED CANONICAL DOCSTRING
  StatsRequestCount? tokenRequests;
}
