import 'package:ably_flutter/ably_flutter.dart';

/// options provided when instantiating a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class ChannelOptions {
  /// Either a [CipherParams] or an options hash in the form of a [String].
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  final Object? cipher;

  /// create channel options with a cipher
  ChannelOptions({this.cipher});
}
