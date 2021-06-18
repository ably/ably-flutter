import '../../../ably_flutter.dart';
import '../common.dart';
import '../message.dart';
import 'presence.dart';

/// options provided when instantiating a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#TB1
class ChannelOptions {
  /// https://docs.ably.com/client-lib-development-guide/features/#TB2b
  final Object cipher;

  /// create channel options with a cipher
  ChannelOptions(this.cipher) : assert(cipher != null, 'cipher cannot be null');
}

/// A named channel through with rest client can interact with ably service.
///
/// The same channel can be interacted with relevant APIs via realtime channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSL1
abstract class RestChannelInterface {
  /// creates a Rest channel instance
  RestChannelInterface(this.rest, this.name);

  /// reference to Rest client
  RestInterface rest;

  /// name of the channel
  String name;

  /// presence interface for this channel
  ///
  /// can only query presence on the channel and presence history
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL3
  RestPresenceInterface get presence;

  /// fetch message history on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL2
  Future<PaginatedResultInterface<Message>> history([RestHistoryParams params]);

  /// publish messages on this channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL1
  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    Object data,
  });

  /// takes a ChannelOptions object and sets or updates the
  /// stored channel options, then indicates success
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSL7
  Future<void> setOptions(ChannelOptions options);
}

/// A collection of rest channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSN1
abstract class RestChannels<T extends RestChannelInterface>
    extends Channels<T> {
  /// instance of a rest client
  RestInterface rest;

  /// instantiates with the ably [RestInterface] instance
  RestChannels(this.rest);
}
