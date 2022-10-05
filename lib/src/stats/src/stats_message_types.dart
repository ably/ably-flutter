import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// MessageTypes contains a breakdown of summary stats data
/// for different (message vs presence) message types
///
/// https://docs.ably.com/client-lib-development-guide/features/#TS6
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains a breakdown of summary stats data for different
/// (channel vs presence) message types.
/// END EDITED CANONICAL DOCSTRING
abstract class StatsMessageTypes {
  /// BEGIN LEGACY DOCSTRING
  /// All messages count (includes both presence & messages).
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageCount]object containing the count and byte value of
  /// messages and presence messages.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageCount? all;

  /// BEGIN LEGACY DOCSTRING
  /// Count of channel messages.
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageCount] object containing the count and byte value of
  /// messages.
  /// END CANONICAL DOCSTRING
  StatsMessageCount? messages;

  /// BEGIN LEGACY DOCSTRING
  /// Count of presence messages.
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [StatsMessageCount] object containing the count and byte value of
  /// presence messages.
  /// END EDITED CANONICAL DOCSTRING
  StatsMessageCount? presence;
}
