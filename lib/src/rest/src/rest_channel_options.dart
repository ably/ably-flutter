import 'package:ably_flutter/src/authentication/authentication.dart';

/// options provided when instantiating a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RestChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  final CipherParams? cipher;

  /// create channel options with a cipher
  RestChannelOptions({this.cipher});
}
