import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// A named channel through with rest client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via realtime channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSL1
class RestChannel extends PlatformObject {
  /// reference to Rest client
  Rest rest;

  /// Channel to receive push notifications on
  PushChannel push;

  /// name of the channel
  String name;

  late RestPresence _presence;

  /// presence interface for this channel
  ///
  /// can only query presence on the channel and presence history
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL3
  RestPresence get presence => _presence;

  /// instantiates with [Rest], [name] and [RestChannelOptions]
  RestChannel(this.rest, this.push, this.name) {
    _presence = RestPresence(this);
  }

  /// createPlatformInstance will return restPlatformObject's handle
  /// as that is what will be required in platforms end to find rest instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async => rest.handle;

  /// fetch message history on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2
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

  /// publish messages on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL1
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

  /// takes a ChannelOptions object and sets or updates the
  /// stored channel options, then indicates success
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL7
  Future<void> setOptions(RestChannelOptions options) =>
      invoke(PlatformMethod.setRestChannelOptions, {
        TxTransportKeys.channelName: name,
        TxTransportKeys.options: options,
      });
}
