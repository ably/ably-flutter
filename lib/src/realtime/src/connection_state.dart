/// See Ably Realtime API documentation for more details.
/// https://docs.ably.com/client-lib-development-guide/features/#connection-states-operations
enum ConnectionState {
  /// specifies that a connection is initialized
  initialized,

  /// specifies that a connection to ably is being established
  connecting,

  /// specifies that a connection to ably is established
  connected,

  /// specifies that a connection to ably is disconnected
  disconnected,

  /// specifies that a connection to ably is suspended
  suspended,

  /// specifies that a connection to ably is closing
  closing,

  /// specifies that a connection to ably is closed
  closed,

  /// specifies that a connection to ably is failed
  failed,
}
