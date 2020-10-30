import 'package:ably_flutter_plugin/ably.dart';
import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RealtimeSubscribeTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const RealtimeSubscribeTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RealtimeSubscribeTestState();
}

class RealtimeSubscribeTestState extends State<RealtimeSubscribeTest> {
  @override
  void initState() {
    super.initState();
    widget.dispatcher.timeout(const Duration(seconds: 45));
    init();
  }

  Future<void> init() async {
    final appKey = await provision('sandbox-');
    final messages = <Map<String, dynamic>>[];

    final realtime = Realtime(
      options: ClientOptions.fromKey(appKey.toString())
        ..environment = 'sandbox'
        ..clientId = 'someClientId'
        ..autoConnect = false,
    );
    await realtime.connect();

    final channel = await realtime.channels.get('test');
    await channel.attach();
    channel.subscribe().listen((message) {
      messages.add(messageToJson(message));
    });

    final name = 'Hello';
    final messageData = [
      null, //null
      'Ably', //string
      [1, 2, 3], //numeric list
      ['hello', 'ably'], //string list
      {
        'hello': 'ably',
        'items': ['1', 2.2, true]
      }, //map
      [
        {'hello': 'ably'},
        'ably',
        'realtime'
      ] //list of map
    ];
    await channel.publish(); //publish without name and data
    await channel.publish(data: messageData[1]); //publish without name
    for (var data in messageData) {
      await channel.publish(name: name, data: data);
    }

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'messages': messages,
    });
  }

  Map<String, dynamic> messageToJson(Message message) {
    return {
      'id': message.id,
      'timestamp': message.timestamp.toIso8601String(),
      'clientId': message.clientId,
      'connectionId': message.connectionId,
      'encoding': message.encoding,
      'data': message.data,
      'name': message.name,
      'extras': message.extras,
    };
  }

  @override
  Widget build(BuildContext context) => Container();
}
