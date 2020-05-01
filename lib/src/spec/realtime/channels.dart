import 'package:ably_flutter_plugin/src/spec/push/channels.dart';
import 'package:ably_flutter_plugin/src/spec/rest/ably_base.dart';
import 'package:ably_flutter_plugin/src/spec/rest/channels.dart';

import '../common.dart';
import '../enums.dart';
import '../message.dart';
import 'presence.dart';


abstract class RealtimeChannel extends EventEmitter<ChannelEvent> { //  embeds EventEmitter<ChannelEvent, ChannelStateChange?> // RTL2a, RTL2d, RTL2e

  RealtimeChannel(this.ably, this.name, this.options);

  AblyBase ably;

  String name;              //Not in IDL
  ChannelOptions options;   //Not in IDL

  ErrorInfo errorReason;
  ChannelState state;
  RealtimePresence presence;
//  ChannelProperties properties;
  PushChannel push;
  List<ChannelMode> modes;
  Map<String, String> params;

  Future<ChannelStateChange> whenState(ChannelState targetState);
  Future<EventListener<ChannelEvent>> createListener();
  Future<void> off();

  Future<void> attach();
  Future<void> detach();
  Future<PaginatedResult<Message>> history([RealtimeHistoryParams params]);
  Future<void> publish({
    Message message,
    List<Message> messages,
    String name,
    dynamic data
  });
  Future<void> subscribe({
    String event,
    List<String> events,
    EventListener<Message> listener
  });
  void unsubscribe({
    String event,
    List<String> events,
    EventListener<Message> listener //TODO check if this is the type that is expected
  });
  void setOptions(ChannelOptions options);
}


class RealtimeChannels<T extends RealtimeChannel> extends Channels<T> {

  RealtimeChannels(AblyBase ably): super(ably);

}