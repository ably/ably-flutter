import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains a breakdown of summary stats data for different (TLS vs non-TLS)
/// connection types.
/// END EDITED CANONICAL DOCSTRING
abstract class StatsConnectionTypes {

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsResourceCount] object containing a breakdown of usage by scope
  /// over TLS connections (both TLS and non-TLS).
  /// END EDITED CANONICAL DOCSTRING
  StatsResourceCount? all;

  /// BEGIN CANONICAL DOCSTRING
  /// A [StatsResourceCount] object containing a breakdown of usage by scope
  /// over non-TLS connections.
  /// END CANONICAL DOCSTRING
  StatsResourceCount? plain;

  /// BEGIN CANONICAL DOCSTRING
  /// A [StatsResourceCount] object containing a breakdown of usage by scope
  /// over TLS connections.
  /// END CANONICAL DOCSTRING
  StatsResourceCount? tls;
}
