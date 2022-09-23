/// BEGIN LEGACY DOCSTRING
/// Set of flags that represent the capabilities of a channel for current client
///
/// See:
/// https://docs.ably.com/client-lib-development-guide/features/#TB2d
/// https://docs.ably.com/client-lib-development-guide/features/#RTL4m
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Describes the possible flags used to configure client capabilities, using
/// [ChannelOptions]{@link ChannelOptions}.
/// END CANONICAL DOCSTRING
enum ChannelMode {
  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can check for presence
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The client can enter the presence set.
  /// END CANONICAL DOCSTRING
  presence,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can publish
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The client can publish messages.
  /// END CANONICAL DOCSTRING
  publish,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can subscribe to messages
  /// END LEGACY DOCSTRING
  subscribe,

  /// BEGIN LEGACY DOCSTRING
  /// specifies that channel can subscribe to presence events
  /// END LEGACY DOCSTRING
  presenceSubscribe,
}
