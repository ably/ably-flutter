import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains state change information emitted by [RestChannel] and
/// [RealtimeChannel] objects.
/// END EDITED CANONICAL DOCSTRING
@immutable
class ChannelStateChange {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The event that triggered this [ChannelState] change.
  /// END EDITED CANONICAL DOCSTRING
  final ChannelEvent event;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The new current [ChannelState].
  /// END EDITED CANONICAL DOCSTRING
  final ChannelState current;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The previous state. For the [ChannelEvent.update] event, this is equal to
  /// the current [ChannelState].
  /// END EDITED CANONICAL DOCSTRING
  final ChannelState previous;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An [ErrorInfo] object containing any information relating to the
  /// transition.
  /// END EDITED CANONICAL DOCSTRING
  final ErrorInfo? reason;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Whether message continuity on this channel is preserved, see
  /// [Nonfatal channel errors](https://ably.com/docs/realtime/channels#nonfatal-errors)
  /// for more info.
  /// END EDITED CANONICAL DOCSTRING
  final bool resumed;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// initializes with [resumed] set to false
  /// END LEGACY DOCSTRING
  const ChannelStateChange({
    required this.current,
    required this.event,
    required this.previous,
    this.reason,
    this.resumed = false,
  });
}
