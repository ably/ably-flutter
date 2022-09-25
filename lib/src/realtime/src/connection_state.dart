/// BEGIN LEGACY DOCSTRING
/// See Ably Realtime API documentation for more details.
/// https://docs.ably.com/client-lib-development-guide/features/#connection-states-operations
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Describes the realtime [Connection]{@link Connection} object states.
/// END CANONICAL DOCSTRING
enum ConnectionState {
  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection is initialized
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A connection with this state has been initialized but no connection has
  /// yet been attempted.
  /// END CANONICAL DOCSTRING
  initialized,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is being established
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A connection attempt has been initiated. The connecting state is entered
  /// as soon as the library has completed initialization, and is reentered each
  /// time connection is re-attempted following disconnection.
  /// END CANONICAL DOCSTRING
  connecting,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is established
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A connection exists and is active.
  /// END CANONICAL DOCSTRING
  connected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is disconnected
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
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
  /// SUSPENDED state.
  /// END CANONICAL DOCSTRING
  disconnected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is suspended
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
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
  /// while it was disconnected, it needs to use
  /// [the History API](https://ably.com/docs/realtime/history).
  /// END CANONICAL DOCSTRING
  suspended,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is closing
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// An explicit request by the developer to close the connection has been sent
  /// to the Ably service. If a reply is not received from Ably within a short
  /// period of time, the connection is forcibly terminated and the connection
  /// state becomes CLOSED.
  /// END CANONICAL DOCSTRING
  closing,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is closed
  /// END LEGACY DOCSTRING
  closed,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is failed
  /// END LEGACY DOCSTRING
  failed,
}
