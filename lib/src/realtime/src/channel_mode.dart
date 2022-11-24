import 'package:ably_flutter/src/realtime/realtime.dart';
import 'package:ably_flutter/src/rest/rest.dart';

/// Describes the possible flags used to configure client capabilities, using
/// [RestChannelOptions] or [RealtimeChannelOptions].
enum ChannelMode {
  /// The client can enter the presence set.
  presence,

  /// The client can publish messages.
  publish,

  /// The client can subscribe to messages.
  subscribe,

  /// The client can receive presence messages.
  presenceSubscribe,
}
