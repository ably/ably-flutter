/// BEGIN LEGACY DOCSTRING
/// See Ably Realtime API documentation for more details.
/// https://docs.ably.com/client-lib-development-guide/features/#channel-states-operations
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Describes the possible states of a [RestChannel]{@link RestChannel}
/// or [RealtimeChannel]{@link RealtimeChannel} object.
/// END CANONICAL DOCSTRING
enum ChannelState {
  /// BEGIN LEGACY DOCSTRING
  /// represents that a channel is initialized and no action was taken
  /// i.e., even auto connect was not triggered - if enabled
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The channel has been initialized but no attach has yet been attempted.
  /// END CANONICAL DOCSTRING
  initialized,

  /// BEGIN LEGACY DOCSTRING
  /// channel is attaching
  /// END LEGACY DOCSTRING
  attaching,

  /// BEGIN LEGACY DOCSTRING
  /// channel is attached
  /// END LEGACY DOCSTRING
  attached,

  /// BEGIN LEGACY DOCSTRING
  /// channel is detaching
  /// END LEGACY DOCSTRING
  detaching,

  /// BEGIN LEGACY DOCSTRING
  /// channel is detached
  /// END LEGACY DOCSTRING
  detached,

  /// BEGIN LEGACY DOCSTRING
  /// channel is suspended
  /// END LEGACY DOCSTRING
  suspended,

  /// BEGIN LEGACY DOCSTRING
  /// channel failed to connect
  /// END LEGACY DOCSTRING
  failed,
}
