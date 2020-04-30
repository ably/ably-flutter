import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ably_flutter_plugin/ably.dart' as ably;
import 'provisioning.dart' as provisioning;

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
  OpState _restCreationState = OpState.NotStarted;
  ably.Ably _ablyPlugin;
  ably.Realtime _realtime;
  ably.Rest _rest;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    print('initPlatformState()');

    final ably.Ably ablyPlugin = ably.Ably();

    String platformVersion;
    String ablyVersion;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ablyPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    try {
      ablyVersion = await ablyPlugin.version;
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
      _ablyPlugin = ablyPlugin;
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

  void createAblyRest() async {
    setState(() { _restCreationState = OpState.InProgress; });

    final clientOptions = ably.ClientOptions.fromKey(_appKey.toString());
    clientOptions.environment = 'sandbox';
    clientOptions.logLevel = ably.LogLevel.verbose;
    clientOptions.logHandler = ({String msg, ably.AblyException exception}){
      print("Custom logger :: $msg $exception");
    };

    ably.Rest rest;
    try{
      rest = await _ablyPlugin.createRest(clientOptions);
    } catch (error) {
      print('Error creating Ably Rest: ${error}');
      setState(() { _restCreationState = OpState.Failed; });
      rethrow;
    }

    setState(() {
      _rest = rest;
      _restCreationState = OpState.Succeeded;
    });

    String name = "Hello";
    dynamic data = "Flutter";
    print('publishing messages... name "$name", message "$data"');
    try {
      await rest.channels.get('test').publish(name, data);
      await rest.channels.get('test').publish(name);
      await rest.channels.get('test').publish();
    } on ably.AblyException catch(e) {
      print("EXCEPTION...!");
      print(e);
      print("ERROR INFO FROM ABLY: \n"
          "    CODE: ${e.errorInfo.code}\n"
          "    STATUS_CODE: ${e.errorInfo.statusCode}\n"
          "    MESSAGE: ${e.errorInfo.message}\n"
          "    REQUESTID: ${e.errorInfo.requestId}\n"
          "    CAUSE: ${e.errorInfo.cause}\n"
          "    HREF: ${e.errorInfo.href}\n");
    }
    print('Message published');
  }

  void createAblyRealtime() async {
    setState(() { _realtimeCreationState = OpState.InProgress; });

    final clientOptions = ably.ClientOptions.fromKey(_appKey.toString());
    clientOptions.environment = 'sandbox';
    clientOptions.logLevel = ably.LogLevel.verbose;
    clientOptions.logHandler = ({String msg, ably.AblyException exception}){
      print("Custom logger :: $msg $exception");
    };
    clientOptions.autoConnect = false;

    ably.Realtime realtime;
    try {
      realtime = await _ablyPlugin.createRealtime(clientOptions);
    } catch (error) {
      print('Error creating Ably Realtime: ${error}');
      setState(() { _realtimeCreationState = OpState.Failed; });
      return;
    }

    final listener = await realtime.connection.createListener();

    setState(() {
      _realtime = realtime;
      _realtimeCreationState = OpState.Succeeded;
    });

    print('Awaiting one event...');
    final event = await listener.once();
    print('The one event arrived: $event');
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
  Widget createRestButton() => button(_restCreationState, createAblyRest, 'Create Ably Rest', 'Create Ably Rest', 'Ably Rest Created');
  Widget createRealtimeButton() => button(_realtimeCreationState, createAblyRealtime, 'Create Ably Realtime', 'Creating Ably Realtime', 'Ably Realtime Created');

  Widget createConnectButton() => FlatButton(
    onPressed: () async {
      print('Calling connect...');
      await _realtime.connect();
      print('Connect call completed.');
    },
    child: Text('Connect'),
  );

  int msgCounter = 0;
  Widget sendRestMessage() => FlatButton(
    onPressed: () async {
      print('Sendimg rest message...');
      await _rest.channels.get('test').publish('Hello', 'Flutter ${++msgCounter}');
      print('Rest message sent.');
      setState(() {});
    },
    color: Colors.yellow,
    child: Text('Publish'),
  );

  @override
  Widget build(BuildContext context) {
    print('widget build');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ably Plugin Example App'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
                children: [
                  Text('Running on: $_platformVersion\n'),
                  Text('Ably version: $_ablyVersion\n'),
                  provisionButton(),
                  Text('App Key: ' + ((_appKey == null) ? 'Ably not provisioned yet.' : _appKey.toString())),
                  Divider(),
                  createRealtimeButton(),
                  Text('Realtime: ' + ((_realtime == null) ? 'Ably Realtime not created yet.' : _realtime.toString())),
                  createConnectButton(),
                  Divider(),
                  createRestButton(),
                  Text('Rest: ' + ((_rest == null) ? 'Ably Rest not created yet.' : _rest.toString())),
                  sendRestMessage(),
                  Text('Rest: press this button to publish a new message with data "Flutter ${msgCounter+1}"'),
                ]
            ),
          ),
        ),
      ),
    );
  }
}
