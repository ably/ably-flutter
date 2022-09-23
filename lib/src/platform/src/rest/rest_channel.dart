import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// A named channel through with rest client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via realtime channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSL1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Enables messages to be published and historic messages to be retrieved for a
/// channel.
/// END CANONICAL DOCSTRING
class RestChannel extends PlatformObject {
  /// BEGIN LEGACY DOCSTRING
  /// reference to Rest client
  /// END LEGACY DOCSTRING
  Rest rest;

  /// BEGIN LEGACY DOCSTRING
  /// Channel to receive push notifications on
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A [PushChannel]{@link PushChannel} object.
  /// END CANONICAL DOCSTRING
  PushChannel push;

  /// BEGIN LEGACY DOCSTRING
  /// name of the channel
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The channel name.
  /// END CANONICAL DOCSTRING
  String name;

  late RestPresence _presence;

  /// BEGIN LEGACY DOCSTRING
  /// presence interface for this channel
  ///
  /// can only query presence on the channel and presence history
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// A [RestPresence]{@link RestPresence} object.
  /// END CANONICAL DOCSTRING
  RestPresence get presence => _presence;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates with [Rest], [name] and [RestChannelOptions]
  /// END LEGACY DOCSTRING
  RestChannel(this.rest, this.push, this.name) {
    _presence = RestPresence(this);
  }

  /// BEGIN LEGACY DOCSTRING
  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  /// END LEGACY DOCSTRING
  @override
  Future<int> createPlatformInstance() async => rest.handle;

  /// BEGIN LEGACY DOCSTRING
  /// fetch message history on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves a [PaginatedResult]{@link PaginatedResult} object, containing an
  /// array of historical [Message]{@link Message} objects for the channel.
  /// If the channel is configured to persist messages, then messages can be
  /// retrieved from history for up to 72 hours in the past. If not, messages
  /// can only be retrieved from history for up to two minutes in the past.
  ///
  /// [start] - The time from which messages are retrieved, specified as
  /// milliseconds since the Unix epoch.
  /// [end] - The time until messages are retrieved, specified as milliseconds
  /// since the Unix epoch.
  /// [direction] - The order for which messages are returned in. Valid values
  /// are backwards which orders messages from most recent to oldest, or
  /// forwards which orders messages from oldest to most recent. The default is
  /// backwards.
  /// [limit] - An upper limit on the number of messages returned. The default
  /// is 100, and the maximum is 1000.
  ///
  /// [PaginatedResult<Message>] - A [PaginatedResult]{@link PaginatedResult}
  /// object containing an array of [Message]{@link Message} objects.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// publish messages on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL1
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Publishes a message to the channel. A callback may optionally be passed in
  /// to this call to be notified of success or failure of the operation.
  ///
  /// [Message] - A [Message]{@link Message} object.
  /// [params] - Optional parameters, such as [quickAck](https://faqs.ably.com/why-are-some-rest-publishes-on-a-channel-slow-and-then-typically-faster-on-subsequent-publishes)
  /// sent as part of the query
  /// string.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// takes a ChannelOptions object and sets or updates the
  /// stored channel options, then indicates success
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL7
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Sets the [ChannelOptions]{@link ChannelOptions} for the channel.
  ///
  /// [options] - A [ChannelOptions]{@link ChannelOptions} object.
  /// END CANONICAL DOCSTRING
  Future<void> setOptions(RestChannelOptions options) =>
      invoke(PlatformMethod.setRestChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });
}
