import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Enables messages to be published and historic messages to be retrieved for a
/// channel.
class RestChannel extends PlatformObject {
  /// @nodoc
  /// reference to Rest client
  Rest rest;

  /// A [PushChannel] object.
  PushChannel push;

  /// The channel name.
  String name;

  late RestPresence _presence;

  /// A [RestPresence] object.
  RestPresence get presence => _presence;

  /// @nodoc
  /// instantiates with [Rest], [name] and [RestChannelOptions]
  RestChannel(this.rest, this.push, this.name) {
    _presence = RestPresence(this);
  }

  /// @nodoc
  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async => rest.handle;

  /// Retrieves a [PaginatedResult] object, containing an array of historical
  /// [Message] objects for the channel using the specified [params].
  ///
  /// If the channel is configured to persist messages, then messages can be
  /// retrieved from history for up to 72 hours in the past. If not, messages
  /// can only be retrieved from history for up to two minutes in the past.
  Future<PaginatedResult<Message>> history([
    RestHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.restHistory,
      {
        TxTransportKeys.channelName: name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<Message>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// Publishes a [message] or list of [messages] to the channel, or a single
  /// message with the given event [name] and [data] payload.
  Future<void> publish({
    Message? message,
    List<Message>? messages,
    String? name,
    Object? data,
  }) async {
    messages ??= [
      if (message == null) Message(name: name, data: data) else message
    ];
    await invoke<void>(PlatformMethod.publish, {
      TxTransportKeys.channelName: this.name,
      TxTransportKeys.messages: messages,
    });
  }

  /// Sets the [options] for the channel.
  Future<void> setOptions(RestChannelOptions options) =>
      invoke(PlatformMethod.setRestChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });
}
