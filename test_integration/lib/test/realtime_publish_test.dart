import 'package:ably_flutter_plugin/ably_flutter_plugin.dart';

import '../test_dispatcher.dart';
import 'app_key_provision_helper.dart';
import 'data.dart';
import 'test_widget_abstract.dart';

class RealtimePublishTest extends TestWidget {
  const RealtimePublishTest(TestDispatcherState dispatcher) : super(dispatcher);

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
    await realtimeMessagesPublishUtil(realtime.channels.get('test'));
    await realtime.close();
    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await realtime.handle,
      'log': logMessages,
    });
  }
}

Future<void> realtimeMessagesPublishUtil(RealtimeChannel channel) async {
  for (final data in messagesToPublish) {
    await channel.publish(name: data[0] as String, data: data[1]);
  }
}
