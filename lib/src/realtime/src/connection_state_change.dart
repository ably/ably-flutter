import '../../error/error.dart';
import 'connection_event.dart';
import 'connection_state.dart';

/// Whenever the connection state changes,
/// a ConnectionStateChange object is emitted on the [Connection] object
///
/// https://docs.ably.com/client-lib-development-guide/features/#TA1
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
  ErrorInfo? reason;

  /// when the client is not connected, a connection attempt will be made
  /// automatically by the library after the number of milliseconds
  /// specified by [retryIn]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#TA2
  int? retryIn;

  /// initializes without any defaults
  ConnectionStateChange(
      this.current,
      this.previous,
      this.event, {
        this.reason,
        this.retryIn,
      });
}
