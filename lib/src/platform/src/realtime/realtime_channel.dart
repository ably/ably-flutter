import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// A named channel through with realtime client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via rest channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTL1
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Enables messages to be published and subscribed to. Also enables historic
/// messages to be retrieved and provides access to the [RealtimePresence]
/// object of a channel.
/// END EDITED CANONICAL DOCSTRING
class RealtimeChannel extends PlatformObject {
  final Realtime _realtime;

  final String _channelName;

  late RealtimePresence _presence;

  /// BEGIN LEGACY DOCSTRING
  /// Required by [RealtimePresence], should not be used in other cases
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [RealtimePresence] object.
  /// END EDITED CANONICAL DOCSTRING
  Realtime get realtime => _realtime;

  /// BEGIN LEGACY DOCSTRING
  /// Required by [RealtimePresence], should not be used in other cases
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel name.
  /// END EDITED CANONICAL DOCSTRING
  String get name => _channelName;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL9
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [RealtimePresence] object.
  /// END EDITED CANONICAL DOCSTRING
  RealtimePresence get presence => _presence;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates with [Rest], [name] and [RealtimeChannelOptions]
  ///
  /// sets default [state] to [ChannelState.initialized] and start listening
  /// for updates to the channel [state]/
  /// END LEGACY DOCSTRING
  RealtimeChannel(Realtime realtime, String channelName)
      : _realtime = realtime,
        _channelName = channelName,
        state = ChannelState.initialized,
        super() {
    _presence = RealtimePresence(this);
    push = PushChannel(_channelName, realtime: _realtime);
    on().listen((event) => state = event.current);
  }

  /// BEGIN LEGACY DOCSTRING
  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime
  /// instance and send message to channel
  /// END LEGACY DOCSTRING
  @override
  Future<int> createPlatformInstance() async => _realtime.handle;

  /// BEGIN LEGACY DOCSTRING
  /// returns channel history based on filters passed as [params]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL10
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves a [PaginatedResult] object, containing an array of historical
  /// [Message] objects for the channel using the specified [params].
  ///
  /// If the channel is configured to persist messages, then messages can be
  /// retrieved from history for up to 72 hours in the past. If not, messages
  /// can only be retrieved from history for up to two minutes in the past.
  /// END EDITED CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// publishes messages onto the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL6
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Publishes a [message] or list of [messages] to the channel, or a single
  /// message with a given event [name] and [data] payload.
  ///
  /// When publish is called with this client library, it won't attempt to
  /// implicitly attach to the channel.
  /// END EDITED CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// will hold reason for failure of attaching to channel in such cases
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An [ErrorInfo] object describing the last error which occurred on the
  /// channel, if any.
  /// END EDITED CANONICAL DOCSTRING
  ErrorInfo? errorReason;

  /// BEGIN LEGACY DOCSTRING
  /// modes of this channel as returned by Ably server
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4m
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An array of [ChannelMode] objects.
  /// END EDITED CANONICAL DOCSTRING
  List<ChannelMode>? modes;

  /// BEGIN LEGACY DOCSTRING
  /// Subset of the params passed via [ClientOptions]
  /// that the server has recognized and validated
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4k
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Optional [channel parameters](https://ably.com/docs/realtime/channels/channel-parameters/overview)
  /// that configure the behavior of the channel.
  /// END EDITED CANONICAL DOCSTRING
  Map<String, String>? params;

  // TODO(tihoic) RTL15 - experimental, ChannelProperties properties;

  /// BEGIN LEGACY DOCSTRING
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH4
  /// (see IDL for more details)
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [PushChannel] object.
  /// END EDITED CANONICAL DOCSTRING
  late PushChannel push;

  /// BEGIN LEGACY DOCSTRING
  /// Current state of the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL2b
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The current [ChannelState] of the channel.
  /// END EDITED CANONICAL DOCSTRING
  ChannelState state;

  /// BEGIN LEGACY DOCSTRING
  /// Attaches the realtime client to this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL4
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Attach to this channel ensuring the channel is created in the Ably system
  /// and all messages published on the channel are received by any channel
  /// listeners registered using [RealtimeChannel.subscribe].
  /// Any resulting channel state change will be emitted to any listeners
  /// registered using the [RealtimeChannel.on] stream. As a convenience,
  /// `attach()` is called implicitly if [RealtimeChannel.subscribe] for the
  /// channel is called, or [RealtimePresence.enter] or
  /// [RealtimePresence.subscribe] are called on the [RealtimePresence] object
  /// for this channel.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> attach() => invoke(PlatformMethod.attachRealtimeChannel, {
        TxTransportKeys.channelName: _channelName,
      });

  /// BEGIN LEGACY DOCSTRING
  /// Detaches the realtime client from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL5
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Detach from this channel. Any resulting channel state change is emitted to
  /// any listeners registered using the [RealtimeChannel.on] stream. Once all
  /// clients globally have detached from the channel, the channel will be
  /// released in the Ably service within two minutes.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> detach() => invoke(PlatformMethod.detachRealtimeChannel, {
        TxTransportKeys.channelName: _channelName,
      });

  /// BEGIN LEGACY DOCSTRING
  /// takes a [RealtimeChannelOptions]] object and sets or updates the
  /// stored channel options
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTL16
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Sets the [options] for the channel.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> setOptions(RealtimeChannelOptions options) =>
      invoke(PlatformMethod.setRealtimeChannelOptions, {
        TxTransportKeys.channelName: _channelName,
        TxTransportKeys.options: options,
      });

  /// BEGIN LEGACY DOCSTRING
  /// stream of channel events with specified [ChannelEvent] type
  /// END LEGACY DOCSTRING
  Stream<ChannelStateChange> on([ChannelEvent? channelEvent]) =>
      listen<ChannelStateChange>(
        PlatformMethod.onRealtimeChannelStateChanged,
        {TxTransportKeys.channelName: _channelName},
      ).where(
        (stateChange) =>
            channelEvent == null || stateChange.event == channelEvent,
      );

  /// BEGIN LEGACY DOCSTRING
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
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Registers a listener for messages on this channel for an event [name] or
  /// multiple event [names].
  ///
  /// Returns a stream, which is called each time one or more matching messages
  /// arrives on the channel.
  /// END CANONICAL DOCSTRING
  Stream<Message> subscribe({String? name, List<String>? names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen<Message>(PlatformMethod.onRealtimeChannelMessage, {
      TxTransportKeys.channelName: _channelName,
    }).where((message) =>
        subscribedNames.isEmpty ||
        subscribedNames.any((n) => n == message.name));
  }
}
