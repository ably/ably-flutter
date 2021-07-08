/// See Ably Realtime API documentation for more details.
enum ChannelEvent {
  /// represents that a channel is initialized and no action was taken
  /// i.e., even auto connect was not triggered - if enabled
  initialized,

  /// channel is attaching
  attaching,

  /// channel is attached
  attached,

  /// channel is detaching
  detaching,

  /// channel is detached
  detached,

  /// channel is suspended
  suspended,

  /// channel failed to connect
  failed,

  /// specifies that a channel state is updated
  update,
}
