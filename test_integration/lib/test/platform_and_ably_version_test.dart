import 'package:ably_flutter_plugin/ably.dart' as ably;
import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';

class PlatformAndAblyVersionTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const PlatformAndAblyVersionTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlatformAndAblyVersionTestState();
}

class PlatformAndAblyVersionTestState extends State<PlatformAndAblyVersionTest> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final platformVersion = await ably.platformVersion();
    final ablyVersion = await ably.version();

    widget.dispatcher.reportTestCompletion({
      'platformVersion': platformVersion,
      'ablyVersion': ablyVersion,
    });
  }

  @override
  Widget build(BuildContext context) => Container();
}
