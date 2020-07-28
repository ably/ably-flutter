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
  ably.ChannelState _realtimeChannelState;
  List<StreamSubscription<ably.ConnectionStateChange>> connectionStateChangeSubscriptions;
  StreamSubscription<ably.ChannelStateChange> channelStateChangeSubscription;
  StreamSubscription<ably.Message> channelMessageSubscription;
  ably.Message channelMessage;

  //Storing different message types here to be publishable
  List<dynamic> messagesToPublish = [
    null,
    "A simple panda...",
    {"I am": null, "and": {"also": "nested", "too": {"deep": true}}},
    [42, {"are": "you"}, "ok?", false, {"I am": null, "and": {"also": "nested", "too": {"deep": true}}}]
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    // This dispose would not be effective in this example as this is a single view
    // but subscriptions must be disposed when listeners are
    // implemented in the actual application
    //
    // See: https://api.flutter.dev/flutter/widgets/State/dispose.html
    channelStateChangeSubscription.cancel();
    connectionStateChangeSubscriptions.forEach((StreamSubscription<ably.ConnectionStateChange> subscription) {
      subscription.cancel();
    });
    super.dispose();
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
      print("App key acquired! `$appKey`");
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
    clientOptions.logLevel = ably.LogLevel.verbose;
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
    StreamSubscription<ably.ConnectionStateChange> alphaSubscription = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      print('RETAINING LISTENER α :: Change event arrived!: ${stateChange.event}');
      setState(() { _realtimeConnectionState = stateChange.current; });
    });

    //DISPOSE ON CONNECTED
    Stream<ably.ConnectionStateChange> stream = await realtime.connection.on();
    StreamSubscription<ably.ConnectionStateChange> omegaSubscription;
    omegaSubscription = stream.listen((ably.ConnectionStateChange stateChange) async {
      print('DISPOSABLE LISTENER ω :: Change event arrived!: ${stateChange.event}');
      if (stateChange.event == ably.ConnectionEvent.connected) {
        await omegaSubscription.cancel();
      }
    });

    //RETAINING LISTENER - β
    StreamSubscription<ably.ConnectionStateChange> betaSubscription = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      print('RETAINING LISTENER β :: Change event arrived!: ${stateChange.event}');
      // NESTED LISTENER - ξ
      // will be registered only when connected event is received by β listener
      StreamSubscription<ably.ConnectionStateChange> etaSubscription = realtime.connection.on().listen((
        ably.ConnectionStateChange stateChange) async {
        // k ξ listeners will be registered
        // and each listener will be called `n-k` times respectively
        // if listener β is called `n` times
        print('NESTED LISTENER ξ: ${stateChange.event}');
      });
      connectionStateChangeSubscriptions.add(etaSubscription);
    });

    StreamSubscription<ably.ConnectionStateChange> preZetaSubscription;
    StreamSubscription<ably.ConnectionStateChange> postZetaSubscription;
    preZetaSubscription = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      //This listener "pre ζ" will be cancelled from γ
      print('NESTED LISTENER "pre ζ": ${stateChange.event}');
    });


    //RETAINING LISTENER - γ
    StreamSubscription<ably.ConnectionStateChange> gammaSubscription = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
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

    connectionStateChangeSubscriptions = [
      alphaSubscription,
      betaSubscription,
      gammaSubscription,
      omegaSubscription,
      preZetaSubscription,
      postZetaSubscription
    ];

    setState(() {
      _realtime = realtime;
      _realtimeCreationState = OpState.Succeeded;
    });
  }

  listenRealtimeChannel(ably.RealtimeChannel channel) async {
    channelStateChangeSubscription =  channel.on().listen((ably.ChannelStateChange stateChange){
      print("New channel state: ${stateChange.current}");
      if(stateChange.reason!=null){
        print("stateChange.reason: ${stateChange.reason}");
      }
      setState((){
        _realtimeChannelState = channel.state;
        print("_realtimeChannelState $_realtimeChannelState");
      });
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
    padding: EdgeInsets.zero,
    onPressed: _realtime?.connect,
    child: Text('Connect'),
  );

  Widget createRTCloseButton() => FlatButton(
    padding: EdgeInsets.zero,
    onPressed: (_realtimeConnectionState==ably.ConnectionState.connected)?_realtime?.close:null,
    child: Text('Close Connection'),
  );

  Widget createChannelAttachButton() => FlatButton(
    padding: EdgeInsets.zero,
    onPressed: (_realtimeConnectionState==ably.ConnectionState.connected)?() async {
      ably.RealtimeChannel channel = _realtime.channels.get("test-channel");
      print("Attaching to channel ${channel.name}: Current state ${channel.state}");
      try {
        await channel.attach();
        print("Attached");
      } on ably.AblyException catch (e) {
        print("Unable to attach to channel: ${e.errorInfo}");
      }
    }:null,
    child: Text('Attach to Channel'),
  );

  Widget createChannelDetachButton() => FlatButton(
    padding: EdgeInsets.zero,
    onPressed: (_realtimeChannelState==ably.ChannelState.attached)?() {
      ably.RealtimeChannel channel = _realtime.channels.get("test-channel");
      print("Detaching from channel ${channel.name}: Current state ${channel.state}");
      channel.detach();
      print("Detached");
    }:null,
    child: Text('Detach from channel'),
  );

  Widget createChannelSubscribeButton() => FlatButton(
    onPressed: (_realtimeChannelState==ably.ChannelState.attached && channelMessageSubscription==null)?() {
      ably.RealtimeChannel channel = _realtime.channels.get("test-channel");
      Stream<ably.Message> messageStream = channel.subscribe(names: ['message-data', 'Hello']);
      channelMessageSubscription = messageStream.listen((ably.Message message){
        print("Channel message recieved: $message\n"
          "\tisNull: ${message.data == null}\n"
          "\tisString ${message.data is String}\n"
          "\tisMap ${message.data is Map}\n"
          "\tisList ${message.data is List}\n");
        setState((){
          channelMessage = message;
        });
      });
      print("Channel messages subscribed");
      setState((){});
    }:null,
    child: Text('Subscribe'),
  );

  Widget createChannelUnSubscribeButton() => FlatButton(
    onPressed: (channelMessageSubscription!=null)?() async {
      await channelMessageSubscription.cancel();
      print("Channel messages ubsubscribed");
      setState((){
        channelMessageSubscription = null;
      });
    }:null,
    child: Text('Unsubscribe'),
  );

  int typeCounter = 0;
  int realtimePublishCounter = 0;
  Widget createChannelPublishButton() => FlatButton(
    onPressed: (_realtimeChannelState==ably.ChannelState.attached)?() async {
      print('Sendimg rest message...');
      dynamic data = messagesToPublish[(realtimePublishCounter++ % messagesToPublish.length)];
      ably.Message m = ably.Message()..data=data..name='Hello';
      if(typeCounter%3 == 0){
        await _realtime.channels.get('test-channel').publish(name: 'Hello', data: data);
      } else if (typeCounter%3 == 1) {
        await _realtime.channels.get('test-channel').publish(message: m);
      } else if (typeCounter%3 == 2) {
        await _realtime.channels.get('test-channel').publish(messages: [m, m]);
      }
      if(realtimePublishCounter!=0 && realtimePublishCounter % messagesToPublish.length == 0){
        typeCounter++;
      }
      print('Realtime message sent.');
      setState(() {});
    }:null,
    color: Colors.yellow,
    child: Text('Publish: ${messagesToPublish[(realtimePublishCounter % messagesToPublish.length)]}'),
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
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 36.0),
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Ably version: $_ablyVersion\n'),
              provisionButton(),
              Text('App Key: ' + ((_appKey == null) ? 'Ably not provisioned yet.' : _appKey.toString())),
              Divider(),
              createRealtimeButton(),
              Text('Realtime: ' + ((_realtime == null) ? 'Ably Realtime not created yet.' : _realtime.toString())),
              Text('Connection State: $_realtimeConnectionState'),
              Text('Channel State: $_realtimeChannelState'),
              Row(
                children: <Widget>[
                  Expanded(child: createRTCConnectButton(),),
                  Expanded(child: createRTCloseButton(), )
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(child: createChannelAttachButton()),
                  Expanded(child: createChannelDetachButton()),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(child: createChannelSubscribeButton()),
                  Expanded(child: createChannelUnSubscribeButton()),
                ],
              ),
              Text('Message from channel: ${((channelMessage == null) ? '-' : channelMessage.data)}'),
              createChannelPublishButton(),
              Divider(),
              createRestButton(),
              Text('Rest: ${((_rest == null) ? 'Ably Rest not created yet.' : _rest.toString())}'),
              sendRestMessage(),
              Text('Rest: press this button to publish a new message with data "Flutter ${msgCounter+1}"'),
            ]
          ),
        ),
      ),
    );
  }
}
