import 'package:ably_flutter/ably_flutter.dart' as ably;

class EncryptedMessagingService {
  static const channelName = 'encrypted-test-channel';
  ably.Realtime? _realtime;
  late ably.RealtimeChannel? _channel;

  EncryptedMessagingService(this._realtime);

  Future<void> connect() async {
    await _realtime!.connect();
    final key = await ably.Crypto.generateRandomKey();
    final params = await ably.Crypto.getDefaultParams(key: key);
    final channelOptions = ably.RealtimeChannelOptions(cipher: params);
    _channel = _realtime!.channels.get(channelName);
    await _channel!.setOptions(channelOptions);
    _channel!.on().listen((event) {
      print('on().listen ChannelState: ${event.current}');
      print('on().listen reason: ${event.reason}');
    });
    _channel!.subscribe().listen((event) {
      print('subscribe().listen name: ${event.name}');
      print('subscribe().listen data: ${event.data}');
    });
  }

  Future<void> publishMessage(String name, Map<String, dynamic> data) async {
    await _channel?.publish(message: ably.Message(name: name, data: data));
  }

  Future<void> detach() async {
    await _channel?.detach();
  }

}