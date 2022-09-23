import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Whenever the channel state changes, a ChannelStateChange object
/// is emitted on the Channel object
///
/// https://docs.ably.com/client-lib-development-guide/features/#TH1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Contains state change information emitted by
/// [RestChannel]{@link RestChannel} and
/// [RealtimeChannel]{@link RealtimeChannel} objects.
/// END CANONICAL DOCSTRING
@immutable
class ChannelStateChange {
  /// BEGIN LEGACY DOCSTRING
  /// the event that generated the channel state change
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH5
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The event that triggered this [ChannelState]{@link ChannelState} change.
  /// END CANONICAL DOCSTRING
  final ChannelEvent event;

  /// BEGIN LEGACY DOCSTRING
  /// current state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The new current [ChannelState]{@link ChannelState}.
  /// END CANONICAL DOCSTRING
  final ChannelState current;

  /// BEGIN LEGACY DOCSTRING
  /// previous state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The previous state. For the [UPDATE]{@link ChannelEvent#UPDATE} event,
  /// this is equal to the current [ChannelState]{@link ChannelState}.
  /// END CANONICAL DOCSTRING
  final ChannelState previous;

  /// BEGIN LEGACY DOCSTRING
  /// reason for failure, in case of a failed state
  ///
  /// If the channel state change includes error information,
  /// then the reason attribute will contain an ErrorInfo
  /// object describing the reason for the error
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// An [ErrorInfo]{@link ErrorInfo} object containing any information relating
  /// to the transition.
  /// END CANONICAL DOCSTRING
  final ErrorInfo? reason;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TH4
  /// END LEGACY DOCSTRING
  final bool resumed;

  /// BEGIN LEGACY DOCSTRING
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
