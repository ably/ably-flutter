import 'common.dart';
import 'enums.dart';

/// connects to Ably service using a [websocket](https://www.ably.io/topic/websockets) connection
///
/// https://docs.ably.io/client-lib-development-guide/features/#RTN1
abstract class Connection
    implements EventEmitter<ConnectionEvent, ConnectionStateChange> {
  /// current state of this connection
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#connection-states-operations
  ConnectionState state;

  /// Error information associated with connection failure
  ///
  /// See:
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN14
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN15
  ErrorInfo errorReason;

  /// A public identifier for this connection, used to identify
  /// this member in presence events and message ids.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN8
  String id;

  /// A unique private connection key provided by Ably that is used to reconnect
  /// and retain connection state following an unexpected disconnection
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN9
  String key;

  /// RTN16b) Connection#recoveryKey is an attribute composed of the
  /// connection key and latest serial received on the connection
  String recoveryKey;

  /// The serial number of the last message to be received on this connection.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN10
  int serial;

  /// Explicitly connects to Ably service if not already connected
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN11
  Future<void> connect();

  /// closes the connection
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN12
  Future<void> close();

  /// ping's ably server
  ///
  /// Will send a ProtocolMessage with action HEARTBEAT the Ably service when
  /// connected and expects a HEARTBEAT message in response
  /// https://docs.ably.io/client-lib-development-guide/features/#RTN13
  Future<int> ping();
}
