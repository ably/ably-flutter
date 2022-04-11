import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Whenever the connection state changes,
/// a ConnectionStateChange object is emitted on the [Connection] object
///
/// https://docs.ably.com/client-lib-development-guide/features/#TA1
@immutable
class ConnectionStateChange {
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  final ConnectionEvent event;

  /// current state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  final ConnectionState current;

  /// previous state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  final ConnectionState previous;

  /// reason for failure, in case of a failed state
  ///
  /// If the channel state change includes error information,
  /// then the reason attribute will contain an ErrorInfo
  /// object describing the reason for the error
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA3
  final ErrorInfo? reason;

  /// when the client is not connected, a connection attempt will be made
  /// automatically by the library after the number of milliseconds
  /// specified by [retryIn]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  final int? retryIn;

  /// initializes without any defaults
  const ConnectionStateChange({
    required this.current,
    required this.event,
    required this.previous,
    this.reason,
    this.retryIn,
  });
}
