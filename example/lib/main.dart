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
  var _subscriptionsToDispose = <StreamSubscription>[];
  StreamSubscription<ably.Message> _channelMessageSubscription;
  ably.Message channelMessage;
  ably.PaginatedResult<ably.Message> _restHistory;

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
    _subscriptionsToDispose.forEach((s) => s.cancel());
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

    final clientOptions = ably.ClientOptions();
    clientOptions.logLevel = ably.LogLevel.verbose;
    clientOptions.logHandler = ({String msg, ably.AblyException exception}){
      print("Custom logger :: $msg $exception");
    };
    clientOptions.defaultTokenParams = ably.TokenParams(ttl: 20000);
    clientOptions.authCallback = (ably.TokenParams params) async
      => ably.TokenRequest.fromMap(await provisioning.getTokenRequest());

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
      await Future.wait([
        rest.channels.get('test').publish(name: name, data: data),
        rest.channels.get('test').publish(name: name)
      ]);
      await rest.channels.get('test').publish(data: data);
      await rest.channels.get('test').publish();
      print('Messages published');
    } on ably.AblyException catch(e) {
      print(e.errorInfo);
    }
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

    try {
      ably.Realtime realtime = ably.Realtime(options: clientOptions);
      listenRealtimeConnection(realtime);
      ably.RealtimeChannel channel = realtime.channels.get("test-channel");
      listenRealtimeChannel(channel);
      setState(() {
        _realtime = realtime;
        _realtimeCreationState = OpState.Succeeded;
      });
    } catch (error) {
      print('Error creating Ably Realtime: ${error}');
      setState(() { _realtimeCreationState = OpState.Failed; });
      rethrow;
    }

  }

  listenRealtimeConnection(ably.Realtime realtime) async {
    var alphaSubscription = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      print('${DateTime.now()} : ConnectionStateChange event: ${stateChange.event}'
        '\nReason: ${stateChange.reason}');
      setState(() { _realtimeConnectionState = stateChange.current; });
    });
    _subscriptionsToDispose.add(alphaSubscription);
  }

  listenRealtimeChannel(ably.RealtimeChannel channel) async {
    var _channelStateChangeSubscription =  channel.on().listen((ably.ChannelStateChange stateChange){
      print("ChannelStateChange: ${stateChange.current}"
        "\nReason: ${stateChange.reason}");
      setState((){
        _realtimeChannelState = channel.state;
      });
    });
    _subscriptionsToDispose.add(_channelStateChangeSubscription);
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
    onPressed: (_realtimeChannelState==ably.ChannelState.attached && _channelMessageSubscription==null)?() {
      ably.RealtimeChannel channel = _realtime.channels.get("test-channel");
      Stream<ably.Message> messageStream = channel.subscribe(names: ['message-data', 'Hello']);
      _channelMessageSubscription = messageStream.listen((ably.Message message){
        print("Channel message received: $message\n"
          "\tisNull: ${message.data == null}\n"
          "\tisString ${message.data is String}\n"
          "\tisMap ${message.data is Map}\n"
          "\tisList ${message.data is List}\n");
        setState((){
          channelMessage = message;
        });
      });
      print("Channel messages subscribed");
      _subscriptionsToDispose.add(_channelMessageSubscription);
    }:null,
    child: Text('Subscribe'),
  );

  Widget createChannelUnSubscribeButton() => FlatButton(
    onPressed: (_channelMessageSubscription!=null)?() async {
      await _channelMessageSubscription.cancel();
      print("Channel messages unsubscribed");
      setState((){
        _channelMessageSubscription = null;
      });
    }:null,
    child: Text('Unsubscribe'),
  );

  int typeCounter = 0;
  int realtimePublishCounter = 0;
  Widget createChannelPublishButton() => FlatButton(
    onPressed: (_realtimeChannelState==ably.ChannelState.attached)?() async {
      print('Sending rest message...');
      dynamic data = messagesToPublish[(realtimePublishCounter++ % messagesToPublish.length)];
      ably.Message m = ably.Message()..data=data..name='Hello';
      try {
        switch(typeCounter % 3){
          case 0:
            await _realtime.channels
              .get('test-channel')
              .publish(name: 'Hello', data: data);
            break;
          case 1:
            await _realtime.channels
              .get('test-channel')
              .publish(message: m);
            break;
          case 2:
            await _realtime.channels
              .get('test-channel')
              .publish(messages: [m, m]);
        }
        if (realtimePublishCounter != 0 &&
          realtimePublishCounter % messagesToPublish.length == 0) {
          typeCounter++;
        }
        print('Realtime message sent.');
        setState(() {});
      }on ably.AblyException catch (e){
        print(e);
      }
    }:null,
    color: Colors.yellow,
    child: Text('Publish: ${messagesToPublish[(realtimePublishCounter % messagesToPublish.length)]}'),
  );

  int msgCounter = 1;
  Widget sendRestMessage() => FlatButton(
    onPressed: () async {
      print('Sending rest message');
      try {
        await _rest.channels.get('test').publish(
          name: 'Hello',
          data: 'Flutter $msgCounter'
        );
        print('Rest message sent.');
        setState((){ ++msgCounter; });
      }on ably.AblyException catch (e){
        print("Rest message sending failed:: $e :: ${e.errorInfo}");
      }
    },
    color: Colors.yellow,
    child: Text('Publish'),
  );

  Widget getRestChannelHistory() => FlatButton(
    onPressed: () async {
      bool next = _restHistory?.hasNext() ?? false;
      print('Rest history: getting ${next ? 'next' : 'first'} page');
      try {
        if (_restHistory == null || _restHistory.items.isEmpty) {
          ably.PaginatedResult<ably.Message> result = await _rest.channels
              .get('test')
              .history(
                  ably.RestHistoryParams(direction: 'forwards', limit: 10));
          _restHistory = result;
        } else if (next) {
          _restHistory = await _restHistory.next();
        } else {
          _restHistory = await _restHistory.first();
        }
        setState(() {});
      } on ably.AblyException catch (e) {
        print("failed to get history:: $e :: ${e.errorInfo}");
      }
    },
    color: Colors.yellow,
    child: Text('Get history'),
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
              Text('Rest: press this button to publish a new message with data "Flutter ${msgCounter}"'),
              getRestChannelHistory(),
              Text('History: ${_restHistory?.items?.map((m) => '${m.name}:${m.data?.toString()}')}'),
            ]
          ),
        ),
      ),
    );
  }
}
