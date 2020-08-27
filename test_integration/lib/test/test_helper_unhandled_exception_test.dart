import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';

class TestHelperUnhandledExceptionTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  TestHelperUnhandledExceptionTest(this.dispatcher, {Key key})
      : super(key: key) {
    throw 'Unhandled exception';
  }

  @override
  State<StatefulWidget> createState() =>
      TestHelperUnhandledExceptionTestState();
}

class TestHelperUnhandledExceptionTestState
    extends State<TestHelperUnhandledExceptionTest> {
  @override
  Widget build(BuildContext context) => Container();
}
