import 'package:ably_flutter_plugin/src/spec/rest/ably_base.dart';

import '../common.dart';
import '../message.dart';
import 'ably_base.dart';
import 'presence.dart';


abstract class ChannelOptions {
  dynamic cipher;
}

abstract class ChannelBase {

  ChannelBase(this.ably, this.name, this.options);

  AblyBase ably;
  String name;
  ChannelOptions options;
  Presence presence;
}

class Channel extends ChannelBase {

  @override
  Channel(AblyBase ably, String name, ChannelOptions options): super(ably, name, options) {
    this.presence = Presence();
  }

  AblyBase ably;
  ChannelOptions options;
  Presence presence;
  Future<PaginatedResult<Message>> history([RestHistoryParams params]){
    //TODO
    return null;
  }
  Future<void> publish([String name, dynamic data]){
    //TODO
    return null;
  }
}


class RestChannels<T extends Channel> {

  RestChannels(this.ably);

  AblyBase ably;
  Map<String, Channel> _channels = {};

  T createChannel(name, options){
    return Channel(ably, name, options) as T;
  }

  T get(String name, [ChannelOptions options]) {
    if(_channels[name]==null){
      _channels[name] = createChannel(name, options);
    }
    return _channels[name];
  }

  void release(String str) {
    // TODO: implement release
  }

}