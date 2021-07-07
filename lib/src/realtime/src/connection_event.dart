/// Connection event is same as [ConnectionState] except that it also handles
/// update operations on a connection
///
/// See Ably Realtime API documentation for more details.
enum ConnectionEvent {
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

  /// specifies that a connection is updated
  update,
}