import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Contains state change information emitted by [RestChannel] and
/// [RealtimeChannel] objects.
@immutable
class ChannelStateChange {
  /// The event that triggered this [ChannelState] change.
  final ChannelEvent event;

  /// The new current [ChannelState].
  final ChannelState current;

  /// The previous state. For the [ChannelEvent.update] event, this is equal to
  /// the current [ChannelState].
  final ChannelState previous;

  /// An [ErrorInfo] object containing any information relating to the
  /// transition.
  final ErrorInfo? reason;

  /// Whether message continuity on this channel is preserved, see
  /// [Nonfatal channel errors](https://ably.com/docs/realtime/channels#nonfatal-errors)
  /// for more info.
  final bool resumed;

  /// @nodoc
  /// initializes with [resumed] set to false
  const ChannelStateChange({
    required this.current,
    required this.event,
    required this.previous,
    this.reason,
    this.resumed = false,
  });
}
