import 'package:ably_flutter_plugin/ably.dart';
import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RestPublishTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const RestPublishTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RestPublishTestState();
}

class RestPublishTestState extends State<RestPublishTest> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final appKey = await provision('sandbox-');

    final rest = Rest(
      options: ClientOptions.fromKey(appKey.toString())
        ..environment = 'sandbox'
        ..clientId = 'someClientId',
    );

    final name = 'Hello';
    final data = 'Flutter';

    await rest.channels.get('test').publish(name: name, data: data);
    await rest.channels.get('test').publish(name: name);
    await rest.channels.get('test').publish(data: data);
    await rest.channels.get('test').publish();

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await rest.handle,
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
