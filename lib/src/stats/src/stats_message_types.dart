import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains a breakdown of summary stats data for different
/// (channel vs presence) message types.
/// END EDITED CANONICAL DOCSTRING
abstract class StatsMessageTypes {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageCount]object containing the count and byte value of
  /// messages and presence messages.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageCount? all;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageCount] object containing the count and byte value of
  /// messages.
  /// END CANONICAL DOCSTRING
  StatsMessageCount? messages;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageCount] object containing the count and byte value of
  /// presence messages.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageCount? presence;
}
