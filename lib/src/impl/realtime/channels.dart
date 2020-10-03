import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/realtime/realtime.dart';
import 'package:ably_flutter_plugin/src/spec/push/channels.dart';
import 'package:ably_flutter_plugin/src/spec/spec.dart' as spec;
import 'package:flutter/services.dart';

import '../platform_object.dart';

class RealtimePlatformChannel extends PlatformObject
    implements spec.RealtimeChannel {
  @override
  spec.AblyBase ably;

  @override
  String name;

  @override
  spec.ChannelOptions options;

  @override
  spec.RealtimePresence presence;

  RealtimePlatformChannel(this.ably, this.name, this.options) : super() {
    state = spec.ChannelState.initialized;
    on().listen((ChannelStateChange event) {
      state = event.current;
    });
  }

  Realtime get realtimePlatformObject => ably as Realtime;

  /// createPlatformInstance will return realtimePlatformObject's handle
  /// as that is what will be required in platforms end to find realtime instance
  /// and send message to channel
  @override
  Future<int> createPlatformInstance() async =>
      await realtimePlatformObject.handle;

  @override
  Future<spec.PaginatedResult<spec.Message>> history(
      [spec.RealtimeHistoryParams params]) {
    // TODO: implement history
    return null;
  }

  Map<String, dynamic> __payload;

  Map<String, dynamic> get _payload =>
      __payload ??= {'channel': name, if (options != null) 'options': options};

  @override
  Future<void> publish(
      {spec.Message message,
      List<spec.Message> messages,
      String name,
      dynamic data}) async {
    var hasAuthCallback = ably.options.authCallback != null;
    while (hasAuthCallback && realtimePlatformObject.authCallbackInProgress) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    try {
      await invoke(PlatformMethod.publishRealtimeChannelMessage, {
        ..._payload,
        if (messages != null) 'messages': messages,
        if (messages == null && message != null) 'messages': [message],
        if (name != null) 'name': name,
        if (data != null) 'data': data
      });
    } on PlatformException catch (pe) {
      if (hasAuthCallback &&
          pe.code == ErrorCodes.authCallbackFailure.toString()) {
        realtimePlatformObject.authCallbackInProgress = true;
        await publish(name: name, data: data);
      } else {
        throw spec.AblyException(pe.code, pe.message, pe.details);
      }
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
      await invoke(PlatformMethod.attachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
    }
  }

  @override
  Future<void> detach() async {
    try {
      await invoke(PlatformMethod.detachRealtimeChannel, _payload);
    } on PlatformException catch (pe) {
      throw spec.AblyException(pe.code, pe.message, pe.details);
    }
  }

  @override
  Future<void> setOptions(spec.ChannelOptions options) async {
    throw AblyException(null, 'Realtime chanel options are not supported yet.');
  }

  @override
  Stream<ChannelStateChange> on([ChannelEvent channelEvent]) {
    return listen(PlatformMethod.onRealtimeChannelStateChanged, _payload)
        .map((stateChange) => stateChange as ChannelStateChange)
        .where((stateChange) =>
            channelEvent == null || stateChange.event == channelEvent);
  }

  @override
  Stream<spec.Message> subscribe({String name, List<String> names}) {
    final subscribedNames = {name, ...?names}.where((n) => n != null).toList();
    return listen(PlatformMethod.onRealtimeChannelMessage, _payload)
        .map((message) => message as spec.Message)
        .where((message) =>
            subscribedNames.isEmpty ||
            subscribedNames.any((n) => n == message.name));
  }
}

class RealtimePlatformChannels
    extends spec.RealtimeChannels<RealtimePlatformChannel> {
  RealtimePlatformChannels(Realtime ably) : super(ably);

  @override
  RealtimePlatformChannel createChannel(name, options) {
    return RealtimePlatformChannel(ably, name, options);
  }
}
