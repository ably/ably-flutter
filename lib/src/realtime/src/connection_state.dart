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
  initialized,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is being established
  /// END LEGACY DOCSTRING
  connecting,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is established
  /// END LEGACY DOCSTRING
  connected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is disconnected
  /// END LEGACY DOCSTRING
  disconnected,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is suspended
  /// END LEGACY DOCSTRING
  suspended,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a connection to ably is closing
  /// END LEGACY DOCSTRING
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
