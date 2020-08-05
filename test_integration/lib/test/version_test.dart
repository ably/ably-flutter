import 'package:ably_flutter_plugin/ably.dart' as ably;
import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';

class VersionTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const VersionTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VersionTestState();
}

class VersionTestState extends State<VersionTest> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final platformVersion = await ably.platformVersion();
    final ablyVersion = await ably.version();

    widget.dispatcher.completeTest({
      'platformVersion': platformVersion,
      'ablyVersion': ablyVersion,
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
