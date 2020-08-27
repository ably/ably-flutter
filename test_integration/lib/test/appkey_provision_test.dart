import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class AppKeyProvisionTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const AppKeyProvisionTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppKeyProvisionTestState();
}

class AppKeyProvisionTestState extends State<AppKeyProvisionTest> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final appKey = await provision('sandbox-');

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'appKey': appKey.name,
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
