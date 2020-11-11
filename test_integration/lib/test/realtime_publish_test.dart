import 'package:ably_flutter_integration_test/test/test_widget_abstract.dart';
import 'package:ably_flutter_plugin/ably.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RealtimePublishTest extends TestWidget {
  RealtimePublishTest(TestDispatcherState dispatcher) : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() => RealtimePublishTestState();
}

class RealtimePublishTestState extends TestWidgetState<RealtimePublishTest> {
  @override
  Future<void> test() async {
    final appKey = await provision('sandbox-');
    final logMessages = <List<String>>[];

    final realtime = Realtime(
      options: ClientOptions.fromKey(appKey.toString())
        ..environment = 'sandbox'
        ..clientId = 'someClientId'
        ..logLevel = LogLevel.verbose
        ..logHandler =
            ({msg, exception}) => logMessages.add([msg, '$exception']),
    );
    await realtimeMessagesPublishUtil(realtime);
    await realtime.close();
    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await realtime.handle,
      'log': logMessages,
    });
  }
}

Future<void> realtimeMessagesPublishUtil(Realtime realtime) async {
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

  final channel = await realtime.channels.get('test');
  await channel.publish(); //publish without name and data
  await channel.publish(data: messageData[1]); //publish without name
  for (var data in messageData) {
    await channel.publish(name: name, data: data);
  }
}