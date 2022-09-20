/// BEGIN LEGACY DOCSTRING
/// See Ably Realtime API documentation for more details.
/// END LEGACY DOCSTRING
enum ChannelEvent {
  
  /// BEGIN LEGACY DOCSTRING
  /// represents that a channel is initialized and no action was taken
  /// i.e., even auto connect was not triggered - if enabled
  /// END LEGACY DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// specifies that a channel state is updated
  /// END LEGACY DOCSTRING
  update,
}
