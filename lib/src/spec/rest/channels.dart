import 'package:ably_flutter_plugin/src/spec/rest/ably_base.dart';

import '../common.dart';
import '../message.dart';
import 'ably_base.dart';
import 'presence.dart';

abstract class ChannelOptions {
  dynamic cipher;
}

abstract class RestChannel {
  RestChannel(this.ably, this.name, this.options) {
    presence = Presence();
  }

  AblyBase ably;
  String name;
  ChannelOptions options;
  Presence presence;

  Future<PaginatedResultInterface<Message>> history([RestHistoryParams params]);

  Future<void> publish({String name, Object data});
}

abstract class RestChannels<T extends RestChannel> extends Channels<T> {
  RestChannels(AblyBase ably) : super(ably);
}
