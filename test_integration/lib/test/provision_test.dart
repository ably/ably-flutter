import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';
import 'provision_helper.dart';

class ProvisionTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const ProvisionTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProvisionTestState();
}

class ProvisionTestState extends State<ProvisionTest> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final appKey = await provision('sandbox-');

    widget.dispatcher.completeTest(<String, dynamic>{
      'appKey': appKey.name,
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
