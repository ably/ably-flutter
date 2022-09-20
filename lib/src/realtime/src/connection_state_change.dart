import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Whenever the connection state changes,
/// a ConnectionStateChange object is emitted on the [Connection] object
///
/// https://docs.ably.com/client-lib-development-guide/features/#TA1
/// END LEGACY DOCSTRING
@immutable
class ConnectionStateChange {
  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  /// END LEGACY DOCSTRING
  final ConnectionEvent event;

  /// BEGIN LEGACY DOCSTRING
  /// current state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  /// END LEGACY DOCSTRING
  final ConnectionState current;

  /// BEGIN LEGACY DOCSTRING
  /// previous state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  /// END LEGACY DOCSTRING
  final ConnectionState previous;

  /// BEGIN LEGACY DOCSTRING
  /// reason for failure, in case of a failed state
  ///
  /// If the channel state change includes error information,
  /// then the reason attribute will contain an ErrorInfo
  /// object describing the reason for the error
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA3
  /// END LEGACY DOCSTRING
  final ErrorInfo? reason;

  /// BEGIN LEGACY DOCSTRING
  /// when the client is not connected, a connection attempt will be made
  /// automatically by the library after the number of milliseconds
  /// specified by [retryIn]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  /// END LEGACY DOCSTRING
  final int? retryIn;

  /// BEGIN LEGACY DOCSTRING
  /// initializes without any defaults
  /// END LEGACY DOCSTRING
  const ConnectionStateChange({
    required this.current,
    required this.event,
    required this.previous,
    this.reason,
    this.retryIn,
  });
}
