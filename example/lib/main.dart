import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ably_test_flutter_oldskool_plugin/ably.dart' as ably;
import 'package:ably_test_flutter_oldskool_plugin_example/provisioning.dart' as provisioning;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum OpState {
  NotStarted,
  InProgress,
  Succeeded,
  Failed,
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _ablyVersion = 'Unknown';
  OpState _provisioningState = OpState.NotStarted;
  provisioning.AppKey _appKey;
  OpState _realtimeCreationState = OpState.NotStarted;
  ably.Realtime _realtime;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    print('initPlatformState()');
    String platformVersion;
    String ablyVersion;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ably.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    try {
      ablyVersion = await ably.version;
    } on PlatformException {
      ablyVersion = 'Failed to get Ably version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    print('queueing set state');
    setState(() {
      print('set state');
      _platformVersion = platformVersion;
      _ablyVersion = ablyVersion;
    });
  }

  void provisionAbly() async {
    setState(() { _provisioningState = OpState.InProgress; });
    
    provisioning.AppKey appKey;
    try {
      appKey = await provisioning.provision('sandbox-');
    } catch (error) {
      print('Error provisioning Ably: ${error}');
      setState(() { _provisioningState = OpState.Failed; });
      return;
    }
    
    setState(() {
      _appKey = appKey;
      _provisioningState = OpState.Succeeded;
    });
  }

  void createAblyRealtime() async {
    setState(() { _realtimeCreationState = OpState.InProgress; });

    final clientOptions = ably.ClientOptions();

    ably.Realtime realtime;
    try {
      realtime = await ably.Realtime.create(clientOptions);
    } catch (error) {
      print('Error creating Ably Realtime: ${error}');
      setState(() { _realtimeCreationState = OpState.Failed; });
      return;
    }
  }

  // https://github.com/dart-lang/sdk/issues/37498
  // ignore: missing_return
  static String opStateDescription(OpState state, String action, String operating, String done) {
    switch (state) {
      case OpState.NotStarted: return action;
      case OpState.InProgress: return operating + '...';
      case OpState.Succeeded: return done;
      case OpState.Failed: return 'Failed to ' + action;
    }
  }

  // https://github.com/dart-lang/sdk/issues/37498
  // ignore: missing_return
  static Color opStateColor(OpState state) {
    switch (state) {
      case OpState.NotStarted: return Color.fromARGB(255, 192, 192, 255);
      case OpState.InProgress: return Color.fromARGB(255, 192, 192, 192);
      case OpState.Succeeded: return Color.fromARGB(255, 128, 255, 128);
      case OpState.Failed: return Color.fromARGB(255, 255, 128, 128);
    }
  }

  static Widget button(final OpState state, Function action, String actionDescription, String operatingDescription, String doneDescription) => FlatButton(
    onPressed: (state == OpState.NotStarted || state == OpState.Failed) ? action : null,
    child: Text(
      opStateDescription(state, actionDescription, operatingDescription, doneDescription),
    ),
    color: opStateColor(state),
    disabledColor: opStateColor(state),
  );

  Widget provisionButton() => button(_provisioningState, provisionAbly, 'Provision Ably', 'Provisioning Ably', 'Ably Provisioned');
  Widget createRealtimeButton() => button(_realtimeCreationState, createAblyRealtime, 'Create Ably Realtime', 'Creating Ably Realtime', 'Ably Realtime Created');

  @override
  Widget build(BuildContext context) {
    print('widget build');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ably Plugin Example App'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Ably version: $_ablyVersion\n'),
              provisionButton(),
              Text('App Key: ' + ((_appKey == null) ? 'Ably not provisioned yet.' : _appKey.toString())),
              createRealtimeButton(),
              Text('Realtime: ' + ((_realtime == null) ? 'Ably Realtime not created yet.' : _realtime.toString())),              
            ]
          ),
        ),
      ),
    );
  }
}
