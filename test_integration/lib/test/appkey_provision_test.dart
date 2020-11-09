import 'package:ably_flutter_integration_test/test/test_widget_abstract.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class AppKeyProvisionTest extends TestWidget {
  AppKeyProvisionTest(TestDispatcherState dispatcher) : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() => _AppKeyProvisionTestState();
}

class _AppKeyProvisionTestState extends TestWidgetState<AppKeyProvisionTest> {
  @override
  Future<void> test() async {
    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'appKey': (await provision('sandbox-')).toString(),
      'tokenRequest': await getTokenRequest(),
    });
  }
}
