import 'package:ably_flutter/ably_flutter.dart' as ably;

class EncryptedMessagingService {
  static const channelName = 'encrypted-test-channel';
  ably.Realtime? _realtime;
  ably.Rest? _rest;
  ably.RealtimeChannel? _realtimeChannel;
  ably.RestChannel? _restChannel;

  EncryptedMessagingService(this._realtime);

  Future<void> setRest(ably.Rest rest) async {
    _rest = rest;
    _restChannel = _rest!.channels.get(channelName);
    final key = await ably.Crypto.generateRandomKey();
    final params = await ably.Crypto.getDefaultParams(key: key);
    final channelOptions = ably.RestChannelOptions(cipher: params);
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
    final params = await ably.Crypto.getDefaultParams(key: key);
    final channelOptions = ably.RealtimeChannelOptions(cipher: params);
    _realtimeChannel = _realtime!.channels.get(channelName);
    await _realtimeChannel!.setOptions(channelOptions);
    _realtimeChannel!.on().listen((event) {
      print('on().listen ChannelState: ${event.current}');
      print('on().listen reason: ${event.reason}');
    });
    _realtimeChannel!.subscribe().listen((event) {
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
