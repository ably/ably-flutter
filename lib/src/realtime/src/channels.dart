import 'dart:async';

import '../../common/common.dart';
import '../../common/src/channels.dart';
import '../../common/src/event_emitter.dart';
import '../../error/src/error_info.dart';
import '../../message/src/message.dart';
import '../../push_notifications/src/push_channel.dart';
import '../../rest/src/channel_options.dart';
import '../realtime.dart';
import 'channel_event.dart';
import 'channel_state.dart';
import 'channel_state_event.dart';
import 'presence.dart';
import 'realtime.dart';

/// options provided when instantiating a realtime channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class RealtimeChannelOptions extends ChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2c
  final Map<String, String>? params;

  /// https://docs.ably.com/client-lib-development-guide/features/#TB2d
  final List<ChannelMode>? modes;

  /// create channel options with a cipher, params and modes
  RealtimeChannelOptions(Object cipher, {this.params, this.modes})
      : super(cipher);
}

/// A named channel through with realtime client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via rest channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTL1
abstract class RealtimeChannelInterface
    extends EventEmitter<ChannelEvent, ChannelStateChange> {
  /// creates a Realtime channel instance
  RealtimeChannelInterface(this.realtime, this.name);

  /// realtime client instance
  final RealtimeInterface realtime;

  /// name of the channel
  final String name;

  /// will hold reason for failure of attaching to channel in such cases
  ErrorInfo? errorReason;

  /// current state of channel
  abstract ChannelState state;

  /// https://docs.ably.com/client-lib-development-guide/features/#RTL9
  RealtimePresenceInterface get presence;

  // TODO(tihoic) RTL15 - experimental, ChannelProperties properties;

  /// https://docs.ably.com/client-lib-development-guide/features/#RSH4
  /// (see IDL for more details)
  PushChannel? push;

  /// modes of this channel as returned by Ably server
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4m
  List<ChannelMode>? modes;

  /// Subset of the params passed via [ClientOptions]
  /// that the server has recognised and validated
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4k
  Map<String, String>? params;

  /// Attaches the realtime client to this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4
  Future<void> attach();

  /// Detaches the realtime client from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL5
  Future<void> detach();

  /// returns channel history based on filters passed as [params]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10
  Future<PaginatedResultInterface<Message>> history([
    RealtimeHistoryParams? params,
  ]);

  /// publishes messages onto the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL6
  Future<void> publish({
    Message? message,
    List<Message>? messages,
    String? name,
    Object? data,
  });

  /// subscribes for messages on this channel
  ///
  /// there is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be cancelled
  /// by calling [StreamSubscription.cancel]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL7
  Stream<Message?> subscribe({
    String? name,
    List<String>? names,
  });

  /// takes a [RealtimeChannelOptions]] object and sets or updates the
  /// stored channel options
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL16
  Future<void> setOptions(RealtimeChannelOptions options);
}

/// A collection of realtime channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTS1
abstract class RealtimeChannelsInterface<T extends RealtimeChannelInterface>
    extends Channels<T> {
  /// instance of ably realtime client
  RealtimeInterface realtime;

  /// instantiates with the ably [RealtimeInterface] instance
  RealtimeChannelsInterface(this.realtime);
}
