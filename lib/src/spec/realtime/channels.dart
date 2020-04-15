import 'package:ably_flutter_plugin/src/spec/rest/ably_base.dart';
import 'package:ably_flutter_plugin/src/spec/rest/channels.dart';

import '../common.dart';
import '../enums.dart';
import '../message.dart';
import 'presence.dart';


abstract class RealtimeChannelBase extends EventEmitter<ChannelEvent> {

  RealtimeChannelBase(this.ably, this.name, this.options);

  AblyBase ably;
  String name;
  ChannelOptions options;
  ErrorInfo errorReason;
  ChannelState state;
  void setOptions(dynamic options);
  void unsubscribe({
    String event,
    List<String> events,
    EventListener<Message> listener //TODO check if this is the type that is expected
  });
}

class RealtimeChannel extends RealtimeChannelBase {
  RealtimePresence presence;

  RealtimeChannel(AblyBase ably, String name, ChannelOptions options) : super(ably, name, options);

  Future<void> attach() async {
    //TODO impl
    return;
  }
  Future<void> detach() async {
    //TODO impl
    return;
  }
  Future<PaginatedResult<Message>> history([RealtimeHistoryParams params]) async {
    //TODO impl
    return null;
  }
  Future<void> subscribe({
    String event,
    List<String> events,
    EventListener<Message> listener
  }) async {
    //TODO impl
    return;
  }
  Future<void> publish({String name, dynamic data}) async {
    //TODO impl
    return;
  }
  Future<ChannelStateChange> whenState(ChannelState targetState) async {
    //TODO impl
    return null;
  }

  //  Implement events
  @override
  Future<EventListener<ChannelEvent>> createListener() {
    // TODO: implement createListener
    return null;
  }

  @override
  Future<void> off() {
    // TODO: implement off
    return null;
  }

  @override
  void setOptions(options) {
    // TODO: implement setOptions
  }

  @override
  void unsubscribe({String event, List<String> events, EventListener<Message> listener}) {
    // TODO: implement unsubscribe
  }
}


class RealtimeChannels<T extends RealtimeChannel> {

  RealtimeChannels(this.ably);

  AblyBase ably;
  Map<String, RealtimeChannel> _channels;

  T createChannel(name, options){
    return RealtimeChannel(ably, name, options) as T;
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