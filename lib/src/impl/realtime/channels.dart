import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
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

  RealtimePlatformChannel(int ablyHandle, Ably ablyPlugin, int restHandle, this.ably, this.name, this.options)
      : super(ablyHandle, ablyPlugin, restHandle);

  @override
  Future<spec.PaginatedResult<spec.Message>> history([spec.RealtimeHistoryParams params]) {
    // TODO: implement history
    return null;
  }

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
        "channel": this.name,
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
  Future<void> off() {
    // TODO: implement off
    return null;
  }

  @override
  void setOptions(spec.ChannelOptions options) {
    // TODO: implement setOptions
  }

  @override
  Stream<ChannelStateChange> on([ChannelEvent state]) {
    // TODO: implement on
    Stream<ChannelStateChange> stream = listen(PlatformMethod.onRealtimeChannelStateChanged);
    if (state!=null) {
      return stream.takeWhile((ChannelStateChange _stateChange) => _stateChange.event==state);
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

  int ablyHandle;
  Ably ablyPlugin;
  int restHandle;

  RealtimePlatformChannels(this.ablyHandle, this.ablyPlugin, this.restHandle, spec.AblyBase ably): super(ably);

  @override
  RealtimePlatformChannel createChannel(name, options){
    return RealtimePlatformChannel(ablyHandle, ablyPlugin, restHandle, ably, name, options);
  }

}