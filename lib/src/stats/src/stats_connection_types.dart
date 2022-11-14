import 'package:ably_flutter/ably_flutter.dart';

/// Contains a breakdown of summary stats data for different (TLS vs non-TLS)
/// connection types.
abstract class StatsConnectionTypes {
  /// A [StatsResourceCount] object containing a breakdown of usage by scope
  /// over TLS connections (both TLS and non-TLS).
  StatsResourceCount? all;

  /// A [StatsResourceCount] object containing a breakdown of usage by scope
  /// over non-TLS connections.
  StatsResourceCount? plain;

  /// A [StatsResourceCount] object containing a breakdown of usage by scope
  /// over TLS connections.
  StatsResourceCount? tls;
}
