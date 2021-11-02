import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessageEncryptionSliver extends StatelessWidget {
  ably.Realtime? _realtime;
  ably.RealtimeChannel? _channel;

  MessageEncryptionSliver(this._realtime, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Message Encryption',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Text('Realtime client is ${_realtime == null ? "null. Create one. 🚨" : "instantiated. ✅"}'),
        TextButton(
          child: Text('Connect and listen to channel'),
          onPressed: () async {
            final params = await ably.Crypto.getParams();
            final channelOptions =
                ably.RealtimeChannelOptions(cipher: params);
            _channel = _realtime!.channels.get("encrypted");
            _channel!.setOptions(channelOptions);
            _channel!.on().listen((event) {
              print("on().listen: ${event}");
            });
            _channel!.subscribe().listen((event) {
              print("subscribe().listen: ${event}");
            });
            _channel!.attach();
          },
        ),
        TextButton(
          child: Text('Publish encrypted message'),
          onPressed: () async {
            _channel!.publish(
                message: ably.Message(
                    name: "Hello",
                    data: {"payload": "this should be encrypted"}));
          },
        ),
      ],
    );
  }
}
