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

    final channel = await realtime.channels.get('publish-test');

    final name = 'Hello';
    final data = 'Flutter';

    await channel.publish(name: name, data: data);
    await channel.publish(name: name);
    await channel.publish(data: data);
    await channel.publish();

    await realtime.connection.close();

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await realtime.handle,
      'log': logMessages,
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
