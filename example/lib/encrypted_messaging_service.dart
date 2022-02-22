import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:rxdart/rxdart.dart';

import 'constants.dart';

class EncryptedMessagingService {
  final ably.Realtime _realtime;
  final ably.Rest _rest;
  late final ably.RealtimeChannel? _realtimeChannel;
  late final ably.RestChannel? _restChannel;

  final BehaviorSubject<List<ably.Message>> messageHistoryBehaviorSubject =
      BehaviorSubject<List<ably.Message>>.seeded([]);

  ValueStream<List<ably.Message>> get messageHistoryStream =>
      messageHistoryBehaviorSubject.stream;

  EncryptedMessagingService(this._realtime, this._rest) {
    _restChannel = _rest.channels.get(Constants.encryptedChannelName);
    _realtimeChannel = _realtime.channels.get(Constants.encryptedChannelName);
  }

  void clearMessageHistory() {
    messageHistoryBehaviorSubject.add([]);
  }

  Future<void> connectRealtime() async {
    if (_realtime.connection.state != ably.ConnectionState.connected) {
      await _realtime.connect();
    }
  }

  StreamSubscription<ably.Message>? _channelSubscription;
  StreamSubscription<ably.ChannelStateChange>? channelStateChangeSubscription;

  Future<void> logChannelMessages() async {
    await connectRealtime();
    channelStateChangeSubscription = _realtimeChannel!.on().listen((event) {
      print('on().listen ChannelState: ${event.current}');
      print('on().listen reason: ${event.reason}');
    });
    await _realtimeChannel!.attach();
    _channelSubscription ??= _realtimeChannel!.subscribe().listen((event) {
      final newList = List<ably.Message>.from(messageHistoryStream.value)
        ..add(event);
      messageHistoryBehaviorSubject.add(newList);
      print('subscribe().listen name: ${event.name}');
      print('subscribe().listen data: ${event.data}');
    });
  }

  Future<void> publishRealtimeMessage(
      String name, Map<String, dynamic> data) async {
    await _realtimeChannel?.publish(
        message: ably.Message(name: name, data: data));
  }

  Future<void> publishRestMessage(
      String name, Map<String, dynamic> data) async {
    await _restChannel?.publish(message: ably.Message(name: name, data: data));
  }

  Future<void> unsubscribeAndDetach() async {
    await _channelSubscription?.cancel();
    await channelStateChangeSubscription?.cancel();
    _channelSubscription = null;
    channelStateChangeSubscription = null;
    await _realtimeChannel?.detach();
  }
}
