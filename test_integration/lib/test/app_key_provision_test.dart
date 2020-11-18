import '../test_dispatcher.dart';
import 'app_key_provision_helper.dart';
import 'test_widget_abstract.dart';

class AppKeyProvisionTest extends TestWidget {
  const AppKeyProvisionTest(TestDispatcherState dispatcher) : super(dispatcher);

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
