import '../common.dart';
import '../message.dart';
import 'ably_base.dart';
import 'presence.dart';

abstract class ChannelOptions {
  dynamic cipher;
}

abstract class RestChannelInterface {
  RestChannelInterface(
    this.ably,
    this.name,
    this.options,
  ) {
    presence = Presence();
  }

  AblyBase ably;
  String name;
  ChannelOptions options;
  Presence presence;

  Future<PaginatedResultInterface<Message>> history([RestHistoryParams params]);

  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    Object data,
  });
}

abstract class RestChannels<T extends RestChannelInterface>
  extends Channels<T> {
  RestChannels(AblyBase ably) : super(ably);
}
