import 'package:ably_flutter/ably_flutter.dart';

/// Whenever the channel state changes, a ChannelStateChange object
/// is emitted on the Channel object
///
/// https://docs.ably.com/client-lib-development-guide/features/#TH1
class ChannelStateChange {
  /// the event that generated the channel state change
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH5
  final ChannelEvent event;

  /// current state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH2
  final ChannelState current;

  /// previous state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH2
  final ChannelState previous;

  /// reason for failure, in case of a failed state
  ///
  /// If the channel state change includes error information,
  /// then the reason attribute will contain an ErrorInfo
  /// object describing the reason for the error
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TH3
  ErrorInfo? reason;

  /// https://docs.ably.com/client-lib-development-guide/features/#TH4
  final bool resumed;

  /// initializes with [resumed] set to false
  ChannelStateChange(
    this.current,
    this.previous,
    this.event, {
    this.reason,
    this.resumed = false,
  });
}
