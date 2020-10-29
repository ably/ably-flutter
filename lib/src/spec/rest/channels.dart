import 'package:ably_flutter_plugin/src/spec/rest/ably_base.dart';

import '../common.dart';
import '../message.dart';
import 'ably_base.dart';
import 'presence.dart';


abstract class ChannelOptions {
  dynamic cipher;
}

abstract class RestChannel {

  RestChannel(this.ably, this.name, this.options){
    this.presence = Presence();
  }

  AblyBase ably;
  String name;
  ChannelOptions options;
  Presence presence;
  Future<PaginatedResult<Message>> history([RestHistoryParams params]);
  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    dynamic data,
  });
}


abstract class RestChannels<T extends RestChannel> extends Channels<T> {

  RestChannels(ably) : super(ably);

}
