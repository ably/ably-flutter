import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Enables messages to be published and subscribed to.
///
/// Also enables historic messages to be retrieved and provides access to the
/// [RealtimePresence] object of a channel.
class RealtimeChannel extends PlatformObject {
  final Realtime _realtime;

  final String _channelName;

  late RealtimePresence _presence;

  /// A [RealtimePresence] object.
  Realtime get realtime => _realtime;

  /// The channel name.
  String get name => _channelName;

  /// A [RealtimePresence] object.
  RealtimePresence get presence => _presence;

  /// @nodoc
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

  /// @nodoc
  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime
  /// instance and send message to channel
  @override
  Future<int> createPlatformInstance() async => _realtime.handle;

  /// Retrieves a [PaginatedResult] object, containing an array of historical
  /// [Message] objects for the channel using the specified [params].
  ///
  /// If the channel is configured to persist messages, then messages can be
  /// retrieved from history for up to 72 hours in the past. If not, messages
  /// can only be retrieved from history for up to two minutes in the past.
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

  /// Publishes a [message] or list of [messages] to the channel, or a single
  /// message with a given event [name] and [data] payload.
  ///
  /// When publish is called with this client library, it won't attempt to
  /// implicitly attach to the channel.
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

  /// An [ErrorInfo] object describing the last error which occurred on the
  /// channel, if any.
  ErrorInfo? errorReason;

  /// An array of [ChannelMode] objects.
  List<ChannelMode>? modes;

  /// Optional [channel parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview)
  /// that configure the behavior of the channel.
  Map<String, String>? params;

  // TODO(tihoic) RTL15 - experimental, ChannelProperties properties;

  /// A [PushChannel] object.
  late PushChannel push;

  /// The current [ChannelState] of the channel.
  ChannelState state;

  /// Attach to this channel ensuring the channel is created in the Ably system
  /// and all messages published on the channel are received by any channel
  /// listeners registered using [RealtimeChannel.subscribe].
  ///
  /// Any resulting channel state change will be emitted to any listeners
  /// registered using the [RealtimeChannel.on] stream. As a convenience,
  /// `attach()` is called implicitly if [RealtimeChannel.subscribe] for the
  /// channel is called, or [RealtimePresence.enter] or
  /// [RealtimePresence.subscribe] are called on the [RealtimePresence] object
  /// for this channel.
  Future<void> attach() => invoke(PlatformMethod.attachRealtimeChannel, {
        TxTransportKeys.channelName: _channelName,
      });

  /// Detach from this channel. Any resulting channel state change is emitted to
  /// any listeners registered using the [RealtimeChannel.on] stream.
  ///
  /// Once all clients globally have detached from the channel, the channel will
  /// be released in the Ably service within two minutes.
  Future<void> detach() => invoke(PlatformMethod.detachRealtimeChannel, {
        TxTransportKeys.channelName: _channelName,
      });

  /// Sets the [options] for the channel.
  Future<void> setOptions(RealtimeChannelOptions options) =>
      invoke(PlatformMethod.setRealtimeChannelOptions, {
        TxTransportKeys.channelName: _channelName,
        TxTransportKeys.options: options,
      });

  /// Stream of channel events with specified [ChannelEvent] type
  Stream<ChannelStateChange> on([ChannelEvent? channelEvent]) =>
      listen<ChannelStateChange>(
        PlatformMethod.onRealtimeChannelStateChanged,
        {TxTransportKeys.channelName: _channelName},
      ).where(
        (stateChange) =>
            channelEvent == null || stateChange.event == channelEvent,
      );

  /// Registers a listener for messages on this channel for an event [name] or
  /// multiple event [names].
  ///
  /// There is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be cancelled
  /// by calling [StreamSubscription.cancel]
  ///
  /// Returns a stream, which is called each time one or more matching messages
  /// arrives on the channel.
  Stream<Message> subscribe({String? name, List<String>? names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen<Message>(PlatformMethod.onRealtimeChannelMessage, {
      TxTransportKeys.channelName: _channelName,
    }).where((message) =>
        subscribedNames.isEmpty ||
        subscribedNames.any((n) => n == message.name));
  }
}
