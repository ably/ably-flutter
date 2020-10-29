import 'package:ably_flutter_plugin/ably.dart';
import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RealtimePublishTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const RealtimePublishTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RealtimePublishTestState();
}

class RealtimePublishTestState extends State<RealtimePublishTest> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final appKey = await provision('sandbox-');
    final logMessages = <List<String>>[];

    final realtime = Realtime(
      options: ClientOptions.fromKey('$appKey')
        ..environment = 'sandbox'
        ..clientId = 'someClientId'
        ..logLevel = LogLevel.verbose
        ..logHandler =
            ({msg, exception}) => logMessages.add([msg, '$exception']),
    );

    final name = 'Hello';
    final messageData = [
      null,   //null
      'Ably', //string
      [1, 2, 3],  //numeric list
      ['hello', 'ably'], //string list
      {'hello': 'ably', 'items': ['1', 2.2, '3 thousand']},  //map
      [{'hello': 'ably'}, 'ably', 'realtime'] //list of map
    ];

    final channel = await realtime.channels.get('test');
    await channel.publish();  //publish without name and data
    await channel.publish(data: messageData[1]);  //publish without name
    for(var data in messageData){
      await channel.publish(name: name, data: data);
    }

    // TODO(tiholic) throws UnimplementedError
    // await realtime.connection.close();

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await realtime.handle,
      'log': logMessages,
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
