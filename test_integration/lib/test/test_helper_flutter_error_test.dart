import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';

class TestHelperFlutterErrorTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const TestHelperFlutterErrorTest(this.dispatcher, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TestHelperFlutterErrorTestState();
}

class TestHelperFlutterErrorTestState
    extends State<TestHelperFlutterErrorTest> {
  @override
  Widget build(BuildContext context) {
    FlutterError.reportError(const FlutterErrorDetails(
        exception: 'Should become a FlutterError response'));
    return Container();
  }
}
