import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Connection event is same as [ConnectionStateChange] except that it also
/// handles update operations on a connection
///
/// See Ably Realtime API documentation for more details.
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Describes the events emitted by a [Connection] object. An event is
/// either an `UPDATE` or an event from [ConnectionState].
/// END EDITED CANONICAL DOCSTRING
enum ConnectionEvent {
  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection is initialized
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A connection with this state has been initialized but no connection has
  /// yet been attempted.
  /// END EDITED CANONICAL DOCSTRING
  initialized,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is being established
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A connection attempt has been initiated. The connecting state is entered
  /// as soon as the library has completed initialization, and is reentered each
  /// time connection is re-attempted following disconnection.
  /// END EDITED CANONICAL DOCSTRING
  connecting,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is established
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A connection exists and is active.
  /// END EDITED CANONICAL DOCSTRING
  connected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is disconnected
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A temporary failure condition. No current connection exists because there
  /// is no network connectivity or no host is available. The disconnected state
  /// is entered if an established connection is dropped, or if a connection
  /// attempt was unsuccessful. In the disconnected state the library will
  /// periodically attempt to open a new connection (approximately every 15
  /// seconds), anticipating that the connection will be re-established soon
  /// and thus connection and channel continuity will be possible. In this
  /// state, developers can continue to publish messages as they are
  /// automatically placed in a local queue, to be sent as soon as a connection
  /// is reestablished. Messages published by other clients while this client
  /// is disconnected will be delivered to it upon reconnection, so long as the
  /// connection was resumed within 2 minutes. After 2 minutes have elapsed,
  /// recovery is no longer possible and the connection will move to the
  /// `SUSPENDED` state.
  /// END EDITED CANONICAL DOCSTRING
  disconnected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is suspended
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A long term failure condition. No current connection exists because there
  /// is no network connectivity or no host is available. The suspended state is
  /// entered after a failed connection attempt if there has then been no
  /// connection for a period of two minutes. In the suspended state, the
  /// library will periodically attempt to open a new connection every 30
  /// seconds. Developers are unable to publish messages in this state. A new
  /// connection attempt can also be triggered by an explicit call to
  /// [connect()]{@link Connection#connect}. Once the connection has been
  /// re-established, channels will be automatically re-attached. The client has
  /// been disconnected for too long for them to resume from where they left
  /// off, so if it wants to catch up on messages published by other clients
  /// while it was disconnected, it needs to use [the History API](https://ably.com/docs/realtime/history).
  /// END EDITED CANONICAL DOCSTRING
  suspended,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is closing
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An explicit request by the developer to close the connection has been sent
  /// to the Ably service. If a reply is not received from Ably within a short
  /// period of time, the connection is forcibly terminated and the connection
  /// state becomes `CLOSED`.
  /// END EDITED CANONICAL DOCSTRING
  closing,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is closed
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The connection has been explicitly closed by the client. In the closed
  /// state, no reconnection attempts are made automatically by the library,
  /// and clients may not publish messages. No connection state is preserved by
  /// the service or by the library. A new connection attempt can be triggered
  /// by an explicit call to [Connection.connect], which results in a new
  /// connection.
  /// END EDITED CANONICAL DOCSTRING
  closed,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is failed
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// This state is entered if the client library encounters a failure condition
  /// that it cannot recover from. This may be a fatal connection error received
  /// from the Ably service, for example an attempt to connect with an incorrect
  /// API key, or a local terminal error, for example the token in use has
  /// expired and the library does not have any way to renew it. In the failed
  /// state, no reconnection attempts are made automatically by the library, and
  /// clients may not publish messages. A new connection attempt can be
  /// triggered by an explicit call to [Connection.connect].
  /// END EDITED CANONICAL DOCSTRING
  failed,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection is updated
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// An event for changes to connection conditions for which the
  /// [ConnectionState] does not change.
  /// END CANONICAL DOCSTRING
  update,
}
