import 'package:ably_flutter_plugin/ably_flutter_plugin.dart';

import '../test_dispatcher.dart';
import 'app_key_provision_helper.dart';
import 'realtime_publish_test.dart';
import 'test_widget_abstract.dart';

class RealtimePublishWithAuthCallbackTest extends TestWidget {
  const RealtimePublishWithAuthCallbackTest(TestDispatcherState dispatcher)
      : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() =>
      RealtimePublishWithAuthCallbackTestState();
}

class RealtimePublishWithAuthCallbackTestState
    extends TestWidgetState<RealtimePublishWithAuthCallbackTest> {
  @override
  Future<void> test() async {
    var authCallbackInvoked = false;
    final realtime = Realtime(
        options: ClientOptions()
          ..logLevel = LogLevel.verbose
          ..authCallback = ((params) async {
            authCallbackInvoked = true;
            return TokenRequest.fromMap(await getTokenRequest());
          }));
    await realtimeMessagesPublishUtil(realtime.channels.get('test'));
    await realtime.close();

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await realtime.handle,
      'authCallbackInvoked': authCallbackInvoked,
    });
  }
}
