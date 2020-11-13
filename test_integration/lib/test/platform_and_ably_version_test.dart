import 'package:ably_flutter_integration_test/test/test_widget_abstract.dart';
import 'package:ably_flutter_plugin/ably_flutter_plugin.dart' as ably;

import '../test_dispatcher.dart';

class PlatformAndAblyVersionTest extends TestWidget {
  PlatformAndAblyVersionTest(TestDispatcherState dispatcher)
      : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() =>
      PlatformAndAblyVersionTestState();
}

class PlatformAndAblyVersionTestState
    extends TestWidgetState<PlatformAndAblyVersionTest> {
  @override
  Future<void> test() async {
    final platformVersion = await ably.platformVersion();
    final ablyVersion = await ably.version();

    widget.dispatcher.reportTestCompletion({
      'platformVersion': platformVersion,
      'ablyVersion': ablyVersion,
    });
  }
}
