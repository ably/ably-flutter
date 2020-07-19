import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/realtime/realtime.dart';
import 'package:ably_flutter_plugin/src/spec/push/channels.dart';
import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;
import 'package:flutter/services.dart';

import '../platform_object.dart';


class RealtimePlatformChannel extends PlatformObject implements spec.RealtimeChannel{

  @override
  spec.AblyBase ably;

  @override
  String name;

  @override
  spec.ChannelOptions options;

  @override
  spec.RealtimePresence presence;

  RealtimePlatformChannel(this.ably, this.name, this.options): super();

  Realtime get realtimePlatformObject => this.ably as Realtime;

  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async => await realtimePlatformObject.handle;

  @override
  Future<spec.PaginatedResult<spec.Message>> history([spec.RealtimeHistoryParams params]) {
    // TODO: implement history
    return null;
  }

  Map<String, dynamic> get _payload => {
    "channel": this.name,
    "options": this.options
  };

  @override
  Future<void> publish({
    spec.Message message,
    List<spec.Message> messages,
    String name,
    dynamic data
  }) async {
    try {
      await this.invoke(PlatformMethod.publish, {
        //TODO support Message and List<Message>
        ..._payload,
        "name": name,
        "message": data
      });
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
    }
  }

  @override
  spec.ErrorInfo errorReason;

  @override
  List<spec.ChannelMode> modes;

  @override
  Map<String, String> params;

  @override
  PushChannel push;

  @override
  spec.ChannelState state;

  @override
  Future<void> attach() {
    // TODO: implement attach
    return null;
  }

  @override
  Future<void> detach() {
    // TODO: implement detach
    return null;
  }

  @override
  void setOptions(spec.ChannelOptions options) {
    // TODO: implement setOptions
  }

  @override
  Stream<ChannelStateChange> on([ChannelEvent channelEvent]) {
    Stream<ChannelStateChange> stream = listen(PlatformMethod.onRealtimeChannelStateChanged, _payload).transform<ChannelStateChange>(
      StreamTransformer.fromHandlers(
        handleData: (dynamic value, EventSink<ChannelStateChange> sink){
          ChannelStateChange stateChange = value as ChannelStateChange;
          this.state = stateChange.current;
          sink.add(stateChange);
        }
      )
    );
    if (channelEvent!=null) {
      return stream.takeWhile((ChannelStateChange _stateChange) => _stateChange.event==channelEvent);
    }
    return stream;
  }

  @override
  Future<void> subscribe({String event, List<String> events, spec.EventListener<spec.Message> listener}) {
    // TODO: implement subscribe
    return null;
  }

  @override
  void unsubscribe({String event, List<String> events, spec.EventListener<spec.Message> listener}) {
    // TODO: implement unsubscribe
  }

}


class RealtimePlatformChannels extends spec.RealtimeChannels<RealtimePlatformChannel>{

  RealtimePlatformChannels(Realtime ably): super(ably);

  @override
  RealtimePlatformChannel createChannel(name, options){
    return RealtimePlatformChannel(this.ably, name, options);
  }

}
