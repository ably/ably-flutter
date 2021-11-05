import 'dart:convert';
import 'dart:typed_data';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:crypto/crypto.dart';
import 'package:rxdart/rxdart.dart';

class EncryptedMessagingService {
  static const channelName = 'encrypted-test-channel';
  ably.Realtime? _realtime;
  ably.Rest? _rest;
  ably.RealtimeChannel? _realtimeChannel;
  ably.RestChannel? _restChannel;

  final BehaviorSubject<List<ably.Message>> messageHistoryBehaviorSubject =
      BehaviorSubject<List<ably.Message>>.seeded([]);

  ValueStream<List<ably.Message>> get messageHistoryStream =>
      messageHistoryBehaviorSubject.stream;

  static const examplePassword = 'password-to-encrypt-and-decrypt-text';

  Uint8List get keyFromPassword {
    final List<int> data = utf8.encode(examplePassword);
    final digest = sha256.convert(data);
    print('Length of digest: ${digest.bytes.length}');
    return Uint8List.fromList(digest.bytes);
  }

  EncryptedMessagingService(this._realtime);

  Future<void> setRest(ably.Rest rest) async {
    _rest = rest;
    _restChannel = _rest!.channels.get(channelName);

    // final key = await ably.Crypto.generateRandomKey();

    // Using getDefaultParams
    print('keyFromPassword: $keyFromPassword');
    final params = await ably.Crypto.getDefaultParams(key: keyFromPassword);
    final channelOptions = ably.RestChannelOptions(cipher: params);

    // Using withCipherKey
    // final channelOptions = await ably.RestChannelOptions.withCipherKey(key);

    // Using with base64 encoded String
    // final base64Key = base64.encode(key);
    // final channelOptions = await ably.RestChannelOptions.withCipherKey(base64Key);

    await _restChannel!.setOptions(channelOptions);
  }

  Future<void> connectRealtime() async {
    if (_realtime!.connection.state != ably.ConnectionState.connected) {
      await _realtime!.connect();
    }
  }

  Future<void> subscribeToChannel() async {
    await connectRealtime();
    final key = await ably.Crypto.generateRandomKey();
    final params = await ably.Crypto.getDefaultParams(key: keyFromPassword);
    final channelOptions = ably.RealtimeChannelOptions(cipher: params);
    // final channelOptions = await ably.RealtimeChannelOptions.withCipherKey(key);
    _realtimeChannel = _realtime!.channels.get(channelName);
    await _realtimeChannel!.setOptions(channelOptions);
    _realtimeChannel!.on().listen((event) {
      print('on().listen ChannelState: ${event.current}');
      print('on().listen reason: ${event.reason}');
    });
    _realtimeChannel!.subscribe().listen((event) {
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

  Future<void> detach() async {
    await _realtimeChannel?.detach();
  }
}
