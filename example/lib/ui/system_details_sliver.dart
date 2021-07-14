import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/widgets.dart';

class SystemDetailsSliver extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SystemDetailsSliverState();
}

class SystemDetailsSliverState extends State<SystemDetailsSliver> {
  String _platformVersion = 'Unknown';
  String _ablyVersion = 'Unknown';

  @override
  void initState() {
    // Platform messages may fail, so we use a try/catch PlatformException.
    asyncInitState();
  }

  void asyncInitState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) return;
    super.initState();

    try {
      _platformVersion = await ably.platformVersion();
    } on ably.AblyException {
      _platformVersion = 'Failed to get platform version.';
    }
    try {
      _ablyVersion = await ably.version();
    } on ably.AblyException {
      _ablyVersion = 'Failed to get Ably version.';
    }

    if (!mounted) return;
    setState(() {});

    // // Platform messages are asynchronous, so we initialize in an async method.
    // Future<void> initPlatformState() async {
    //   print('initPlatformState()');
    //
    //   String platformVersion;
    //   String ablyVersion;
    //
    //   // Platform messages may fail, so we use a try/catch PlatformException.
    //   try {
    //     platformVersion = await ably.platformVersion();
    //   } on ably.AblyException {
    //     platformVersion = 'Failed to get platform version.';
    //   }
    //   try {
    //     ablyVersion = await ably.version();
    //   } on ably.AblyException {
    //     ablyVersion = 'Failed to get Ably version.';
    //   }
    //
    //   // If the widget was removed from the tree while the asynchronous platform
    //   // message was in flight, we want to discard the reply rather than calling
    //   // setState to update our non-existent appearance.
    //   if (!mounted) return;
    //
    //   print('queueing set state');
    //   setState(() {
    //     print('set state');
    //     _platformVersion = platformVersion;
    //     _ablyVersion = ablyVersion;
    //   });
    // }
    }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'System Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text('Running on: $_platformVersion\n'),
        Text('Ably version: $_ablyVersion\n'),
      ],
    );
  }
}
