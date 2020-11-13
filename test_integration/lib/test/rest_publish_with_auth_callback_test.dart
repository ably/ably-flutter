import 'package:ably_flutter_integration_test/test/rest_publish_test.dart';
import 'package:ably_flutter_plugin/ably_flutter_plugin.dart';
import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RestPublishWithAuthCallbackTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const RestPublishWithAuthCallbackTest(this.dispatcher, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => RestPublishWithAuthCallbackTestState();
}

class RestPublishWithAuthCallbackTestState
    extends State<RestPublishWithAuthCallbackTest> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    widget.dispatcher.reportLog('init start');
    var authCallbackInvoked = false;
    final rest = Rest(
        options: ClientOptions()
          ..clientId = 'someClientId'
          ..logLevel = LogLevel.verbose
          ..authCallback = ((TokenParams params) async {
            authCallbackInvoked = true;
            return TokenRequest.fromMap(await getTokenRequest());
          }));
    await restMessagesPublishUtil(rest);
    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await rest.handle,
      'authCallbackInvoked': authCallbackInvoked
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
