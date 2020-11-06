import 'package:ably_flutter_integration_test/test/realtime_publish_test.dart';
import 'package:ably_flutter_integration_test/test/test_widget_abstract.dart';
import 'package:ably_flutter_plugin/ably.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RealtimePublishWithAuthCallbackTest extends TestWidget {
  RealtimePublishWithAuthCallbackTest(TestDispatcherState dispatcher)
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
          ..clientId = 'someClientId'
          ..logLevel = LogLevel.verbose
          ..authCallback = ((TokenParams params) async {
            authCallbackInvoked = true;
            return TokenRequest.fromMap(await getTokenRequest());
          }));
    await realtimeMessagesPublishUtil(realtime);

    // TODO(tiholic) throws UnimplementedError
    // await realtime.connection.close();

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await realtime.handle,
      'authCallbackInvoked': authCallbackInvoked,
    });
  }
}
