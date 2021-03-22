import '../../../ably_flutter.dart';
import '../common.dart';
import '../message.dart';
import 'presence.dart';

/// options provided when instantiating a channel
///
/// https://docs.ably.io/client-lib-development-guide/features/#TB1
abstract class ChannelOptions {
  /// https://docs.ably.io/client-lib-development-guide/features/#TB2b
  dynamic cipher;
// TODO add params and modes for realtime channel options
}

/// A named channel through with rest client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via realtime channel.
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSL1
abstract class RestChannelInterface {
  /// creates a Rest channel instance
  RestChannelInterface(
    this.rest,
    this.name,
    this.options,
  );

  /// reference to Rest client
  RestInterface rest;

  /// name of the channel
  String name;

  /// options of the channel
  ChannelOptions options;

  /// presence interface for this channel
  ///
  /// can only query presence on the channel and presence history
  /// https://docs.ably.io/client-lib-development-guide/features/#RSL3
  RestPresenceInterface presence;

  /// fetch message history on this channel
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSL2
  Future<PaginatedResultInterface<Message>> history([RestHistoryParams params]);

  /// publish messages on this channel
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSL1
  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    Object data,
  });

  /// takes a ChannelOptions object and sets or updates the
  /// stored channel options, then indicates success
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSL7
  Future<void> setOptions(ChannelOptions options);
}

/// A collection of rest channel objects
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSN1
abstract class RestChannels<T extends RestChannelInterface>
    extends Channels<T> {
  /// instance of a rest client
  RestInterface rest;

  /// instantiates with the ably [RestInterface] instance
  RestChannels(this.rest);
}
