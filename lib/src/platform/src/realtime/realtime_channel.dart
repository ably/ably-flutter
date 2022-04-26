import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// A named channel through with realtime client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via rest channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTL1
class RealtimeChannel extends PlatformObject {
  final Realtime _realtime;

  final String _channelName;

  late RealtimePresence _presence;

  /// Required by [RealtimePresence], should not be used in other cases
  Realtime get realtime => _realtime;

  /// Required by [RealtimePresence], should not be used in other cases
  String get name => _channelName;

  /// https://docs.ably.com/client-lib-development-guide/features/#RTL9
  RealtimePresence get presence => _presence;

  /// instantiates with [Rest], [name] and [RealtimeChannelOptions]
  ///
  /// sets default [state] to [ChannelState.initialized] and start listening
  /// for updates to the channel [state]/
  RealtimeChannel(Realtime realtime, String channelName)
      : _realtime = realtime,
        _channelName = channelName,
        state = ChannelState.initialized,
        super() {
    _presence = RealtimePresence(this);
    push = PushChannel(_channelName, realtime: _realtime);
    on().listen((event) => state = event.current);
  }

  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime
  /// instance and send message to channel
  @override
  Future<int> createPlatformInstance() async => _realtime.handle;

  /// returns channel history based on filters passed as [params]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10
  Future<PaginatedResult<Message>> history([
    RealtimeHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage<dynamic>>(
        PlatformMethod.realtimeHistory, {
      TxTransportKeys.channelName: _channelName,
      if (params != null) TxTransportKeys.params: params,
    });
    return PaginatedResult<Message>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// publishes messages onto the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL6
  Future<void> publish({
    Message? message,
    List<Message>? messages,
    String? name,
    Object? data,
  }) async {
    messages ??= [
      if (message == null) Message(name: name, data: data) else message
    ];
    await invoke<void>(PlatformMethod.publishRealtimeChannelMessage, {
      TxTransportKeys.channelName: _channelName,
      TxTransportKeys.messages: messages,
    });
  }

  /// will hold reason for failure of attaching to channel in such cases
  ErrorInfo? errorReason;

  /// modes of this channel as returned by Ably server
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4m
  List<ChannelMode>? modes;

  /// Subset of the params passed via [ClientOptions]
  /// that the server has recognized and validated
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4k
  Map<String, String>? params;

  // TODO(tihoic) RTL15 - experimental, ChannelProperties properties;

  /// https://docs.ably.com/client-lib-development-guide/features/#RSH4
  /// (see IDL for more details)
  late PushChannel push;

  /// Current state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL2b
  ChannelState state;

  /// Attaches the realtime client to this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4
  Future<void> attach() => invoke(PlatformMethod.attachRealtimeChannel, {
        TxTransportKeys.channelName: _channelName,
      });

  /// Detaches the realtime client from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL5
  Future<void> detach() => invoke(PlatformMethod.detachRealtimeChannel, {
        TxTransportKeys.channelName: _channelName,
      });

  /// takes a [RealtimeChannelOptions]] object and sets or updates the
  /// stored channel options
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL16
  Future<void> setOptions(RealtimeChannelOptions options) =>
      invoke(PlatformMethod.setRealtimeChannelOptions, {
        TxTransportKeys.channelName: _channelName,
        TxTransportKeys.options: options,
      });

  /// stream of channel events with specified [ChannelEvent] type
  Stream<ChannelStateChange> on([ChannelEvent? channelEvent]) =>
      listen<ChannelStateChange>(
        PlatformMethod.onRealtimeChannelStateChanged,
        {TxTransportKeys.channelName: _channelName},
      ).where(
        (stateChange) =>
            channelEvent == null || stateChange.event == channelEvent,
      );

  /// subscribes for messages on this channel
  ///
  /// there is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be cancelled
  /// by calling [StreamSubscription.cancel]
  ///
  /// Warning: the name/ names are not channel names, but message names.
  /// See [Message] for more information.
  ///
  /// Calling subscribe the first time on a channel will automatically attach
  /// that channel. If a channel is detached, subscribing again will not
  /// reattach the channel. Remember to call [RealtimeChannel.attach]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL7
  Stream<Message> subscribe({String? name, List<String>? names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen<Message>(PlatformMethod.onRealtimeChannelMessage, {
      TxTransportKeys.channelName: _channelName,
    }).where((message) =>
        subscribedNames.isEmpty ||
        subscribedNames.any((n) => n == message.name));
  }
}
