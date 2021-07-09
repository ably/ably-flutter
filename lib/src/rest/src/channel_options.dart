/// options provided when instantiating a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class ChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  final Object cipher;

  /// create channel options with a cipher
  ChannelOptions(this.cipher);
}
