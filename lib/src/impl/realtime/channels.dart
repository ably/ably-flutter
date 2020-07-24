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

  RealtimePlatformChannel(this.ably, this.name, this.options): super() {
    this.handle;  //proactively acquiring handle
    this.state = spec.ChannelState.initialized;
    this.on().listen((ChannelStateChange event) {
      this.state = event.current;
      print("updating state! ${this.state}");
    });
  }

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
    if(options!=null) "options": options
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
  Future<void> attach() async {
    try {
      await this.invoke(PlatformMethod.attachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
    }
  }

  @override
  Future<void> detach() async {
    try {
      await this.invoke(PlatformMethod.detachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
    }
  }

  @override
  Future<void> setOptions(spec.ChannelOptions options) async {
    throw AblyException(
      null,
      "Realtime chanel options are not supported yet."
    );
  }

  @override
  Stream<ChannelStateChange> on([ChannelEvent channelEvent]) {
    Stream<ChannelStateChange> stream = listen(PlatformMethod.onRealtimeChannelStateChanged, _payload).transform<ChannelStateChange>(
      StreamTransformer.fromHandlers(
        handleData: (dynamic value, EventSink<ChannelStateChange> sink){
          ChannelStateChange stateChange = value as ChannelStateChange;
          if (channelEvent!=null) {
            if (stateChange.event==channelEvent) {
              sink.add(stateChange);
            }
          } else {
            sink.add(stateChange);
          }
        }
      )
    );
    return stream;
  }

  @override
  Stream<spec.Message> subscribe({
    String name,
    List<String> names
  }) {
    Stream<spec.Message> stream = listen(PlatformMethod.onRealtimeChannelMessage, _payload).transform<spec.Message>(
      StreamTransformer.fromHandlers(
        handleData: (dynamic value, EventSink<spec.Message> sink){
          spec.Message message = value as spec.Message;
          if (names!=null){
            if(names.contains(message.name)){
              sink.add(message);
            }
          } else if (name!=null) {
            if(message.name==name){
              sink.add(message);
            }
          } else {
            sink.add(message);
          }
        }
      )
    );
    return stream;
  }

}


class RealtimePlatformChannels extends spec.RealtimeChannels<RealtimePlatformChannel>{

  RealtimePlatformChannels(Realtime ably): super(ably);

  @override
  RealtimePlatformChannel createChannel(name, options){
    return RealtimePlatformChannel(this.ably, name, options);
  }

}
