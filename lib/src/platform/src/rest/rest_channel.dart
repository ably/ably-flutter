import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Enables messages to be published and historic messages to be retrieved for a
/// channel.
/// END EDITED CANONICAL DOCSTRING
class RestChannel extends PlatformObject {
  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// reference to Rest client
  /// END LEGACY DOCSTRING
  Rest rest;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [PushChannel] object.
  /// END EDITED CANONICAL DOCSTRING
  PushChannel push;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel name.
  /// END EDITED CANONICAL DOCSTRING
  String name;

  late RestPresence _presence;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [RestPresence] object.
  /// END EDITED CANONICAL DOCSTRING
  RestPresence get presence => _presence;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// instantiates with [Rest], [name] and [RestChannelOptions]
  /// END LEGACY DOCSTRING
  RestChannel(this.rest, this.push, this.name) {
    _presence = RestPresence(this);
  }

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  /// END LEGACY DOCSTRING
  @override
  Future<int> createPlatformInstance() async => rest.handle;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves a [PaginatedResult] object, containing an array of historical
  /// [Message] objects for the channel using the specified [params].
  ///
  /// If the channel is configured to persist messages, then messages can be
  /// retrieved from history for up to 72 hours in the past. If not, messages
  /// can only be retrieved from history for up to two minutes in the past.
  /// END EDITED CANONICAL DOCSTRING
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

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Publishes a [message] or list of [messages] to the channel, or a single
  /// message with the given event [name] and [data] payload.
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
    await invoke<void>(PlatformMethod.publish, {
      TxTransportKeys.channelName: this.name,
      TxTransportKeys.messages: messages,
    });
  }

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Sets the [options] for the channel.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> setOptions(RestChannelOptions options) =>
      invoke(PlatformMethod.setRestChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });
}
