import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  ably.Realtime _realtime;
  ably.Rest _rest;
  ably.ConnectionState _realtimeConnectionState;

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
      platformVersion = await ably.platformVersion();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    try {
      ablyVersion = await ably.version();
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
      rest = ably.Rest(options: clientOptions);
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
      await rest.channels.get('test').publish(name: name, data: data);
      await rest.channels.get('test').publish(name: name);
      await rest.channels.get('test').publish(data: data);
      await rest.channels.get('test').publish();
    } on ably.AblyException catch(e) {
      print(e.errorInfo);
    }
    print('Message published');

    // set state here as handle will have been acquired before calling
    // publish on channels above...
    setState(() {});
  }

  void createAblyRealtime() async {
    setState(() { _realtimeCreationState = OpState.InProgress; });

    final clientOptions = ably.ClientOptions.fromKey(_appKey.toString());
    clientOptions.environment = 'sandbox';
    clientOptions.logLevel = ably.LogLevel.error;
    clientOptions.logHandler = ({String msg, ably.AblyException exception}){
      print("Custom logger :: $msg $exception");
    };
    clientOptions.autoConnect = false;

    ably.Realtime realtime;
    try {
      realtime = ably.Realtime(options: clientOptions);
      listenRealtimeConnection(realtime);
      ably.RealtimeChannel channel = realtime.channels.get("test-channel");
      listenRealtimeChannel(channel);
    } catch (error) {
      print('Error creating Ably Realtime: ${error}');
      setState(() { _realtimeCreationState = OpState.Failed; });
      rethrow;
    }

  }

  listenRealtimeConnection(ably.Realtime realtime) async {
    //One can listen from multiple listeners on the same event,
    // and must cancel each subscription one by one
    //RETAINING LISTENER - α
    realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      print('RETAINING LISTENER α :: Change event arrived!: ${stateChange.event}');
      setState(() { _realtimeConnectionState = stateChange.current; });
    });

    //DISPOSE ON CONNECTED
    Stream<ably.ConnectionStateChange> stream = await realtime.connection.on();
    StreamSubscription subscription;
    subscription = stream.listen((ably.ConnectionStateChange stateChange) async {
      print('DISPOSABLE LISTENER ω :: Change event arrived!: ${stateChange.event}');
      if (stateChange.event == ably.ConnectionEvent.connected) {
        await subscription.cancel();
      }
    });

    //RETAINING LISTENER - β
    realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      print('RETAINING LISTENER β :: Change event arrived!: ${stateChange.event}');
      // NESTED LISTENER - ξ
      // will be registered only when connected event is received by β listener
      realtime.connection.on().listen((
        ably.ConnectionStateChange stateChange) async {
        // k ξ listeners will be registered
        // and each listener will be called `n-k` times respectively
        // if listener β is called `n` times
        print('NESTED LISTENER ξ: ${stateChange.event}');
      });
    });

    StreamSubscription preZetaSubscription;
    StreamSubscription postZetaSubscription;
    preZetaSubscription = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      //This listener "pre ζ" will be cancelled from γ
      print('NESTED LISTENER "pre ζ": ${stateChange.event}');
    });


    //RETAINING LISTENER - γ
    realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      print('RETAINING LISTENER γ :: Change event arrived!: ${stateChange.event}');
      if (stateChange.event == ably.ConnectionEvent.connected) {
        await preZetaSubscription.cancel();  //by the time this cancel is triggered, preZeta will already have received current event.
        await postZetaSubscription.cancel(); //by the time this cancel is triggered, postZeta hasn't received the event yet. And will never receive as it is cancelled.
      }
    });

    postZetaSubscription = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      //This listener "post ζ" will be cancelled from γ
      print('NESTED LISTENER "post ζ": ${stateChange.event}');
    });

    setState(() {
      _realtime = realtime;
      _realtimeCreationState = OpState.Succeeded;
    });
  }

  listenRealtimeChannel(ably.RealtimeChannel channel) async {
    StreamSubscription<ably.ChannelStateChange> subscription;
    subscription =  channel.on().listen((ably.ChannelStateChange stateChange){
      print("New channel state: ${stateChange.current}");
      //stop listening on detach
      if(stateChange.current == ably.ChannelState.detached){
        subscription.cancel();
      }
    });
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

  Widget createRTCConnectButton() => FlatButton(
    onPressed: _realtime?.connect,
    child: Text('Connect'),
  );

  Widget createRTCloseButton() => FlatButton(
    onPressed: _realtime?.close,
    child: Text('Close Connection'),
  );

  int msgCounter = 0;
  Widget sendRestMessage() => FlatButton(
    onPressed: () async {
      print('Sendimg rest message...');
      await _rest.channels.get('test').publish(
        name: 'Hello',
        data: 'Flutter ${++msgCounter}'
      );
      print('Rest message sent.');
      setState(() {});
    },
    color: Colors.yellow,
    child: Text('Publish'),
  );

  @override
  Widget build(BuildContext context) {
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
                Text('Connection Status: $_realtimeConnectionState'),
                createRTCConnectButton(),
                createRTCloseButton(),
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
