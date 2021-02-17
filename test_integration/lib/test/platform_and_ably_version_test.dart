import 'package:ably_flutter/ably_flutter.dart' as ably;

import '../test_dispatcher.dart';
import 'test_widget_abstract.dart';

class PlatformAndAblyVersionTest extends TestWidget {
  const PlatformAndAblyVersionTest(TestDispatcherState dispatcher)
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
