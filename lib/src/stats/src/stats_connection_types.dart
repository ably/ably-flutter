import 'package:ably_flutter/ably_flutter.dart';

/// ConnectionTypes contains a breakdown of summary stats data
/// for different (TLS vs non-TLS) connection types
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS4
class StatsConnectionTypes {
  /// Creates instance of [StatsConnectionTypes]
  StatsConnectionTypes({this.all, this.plain, this.tls});

  /// All connection count (includes both TLS & non-TLS connections).
  StatsResourceCount? all;

  /// Non-TLS connection count (unencrypted).
  StatsResourceCount? plain;

  /// TLS connection count.
  StatsResourceCount? tls;
}
