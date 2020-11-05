import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';

abstract class TestWidget extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const TestWidget(this.dispatcher, {Key key}) : super(key: key);
}

abstract class TestWidgetState<T extends TestWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    test();
  }

  Future<void> test();

  @override
  Widget build(BuildContext context) => Container();
}
