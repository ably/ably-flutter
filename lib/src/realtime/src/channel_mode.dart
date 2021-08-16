/// Set of flags that represent the capabilities of a channel for current client
///
/// See:
/// https://docs.ably.com/client-lib-development-guide/features/#TB2d
/// https://docs.ably.com/client-lib-development-guide/features/#RTL4m
enum ChannelMode {
  /// specifies that channel can check for presence
  presence,

  /// specifies that channel can publish
  publish,

  /// specifies that channel can subscribe to messages
  subscribe,

  /// specifies that channel can subscribe to presence events
  presenceSubscribe,
}
