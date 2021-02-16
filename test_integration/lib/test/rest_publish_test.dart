import 'package:ably_flutter_plugin/ably_flutter_plugin.dart';

import '../test_dispatcher.dart';
import 'app_key_provision_helper.dart';
import 'data.dart';
import 'test_widget_abstract.dart';

class RestPublishTest extends TestWidget {
  const RestPublishTest(TestDispatcherState dispatcher) : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() => RestPublishTestState();
}

class RestPublishTestState extends TestWidgetState<RestPublishTest> {
  @override
  Future<void> test() async {
    widget.dispatcher.reportLog('init start');
    final appKey = await provision('sandbox-');
    final logMessages = <List<String>>[];

    final rest = Rest(
      options: ClientOptions.fromKey(appKey.toString())
        ..environment = 'sandbox'
        ..clientId = 'someClientId'
        ..logLevel = LogLevel.verbose
        ..logHandler =
            ({msg, exception}) => logMessages.add([msg, exception.toString()]),
    );
    await restMessagesPublishUtil(rest.channels.get('test'));
    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await rest.handle,
      'log': logMessages,
    });
  }
}

Future<void> restMessagesPublishUtil(RestChannel channel) async {
  for (final data in messagesToPublish) {
    await channel.publish(name: data[0] as String, data: data[1]);
  }
}
