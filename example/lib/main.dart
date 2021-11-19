import 'dart:async';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/encrypted_messaging_service.dart';
import 'package:ably_flutter_example/op_state.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_handlers.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/message_encryption/message_encryption_sliver.dart';
import 'package:ably_flutter_example/ui/paginated_result_viewer.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_sliver.dart';
import 'package:ably_flutter_example/ui/system_details_sliver.dart';
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:ably_flutter_example/ui/utilities.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Before calling any Ably methods, ensure the widget binding is ready.
  WidgetsFlutterBinding.ensureInitialized();
  PushNotificationHandlers.setUpEventHandlers();
  PushNotificationHandlers.setUpMessageHandlers();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

const defaultChannel = Constants.channelName;

class _MyAppState extends State<MyApp> {
  final String _apiKey = const String.fromEnvironment(Constants.ablyApiKey);
  ably.Realtime? _realtime;
  ably.Rest? _rest;
  EncryptedMessagingService? encryptedMessagingService;
  ably.ConnectionState? _realtimeConnectionState;
  ably.ChannelState? _realtimeChannelState;
  final _subscriptionsToDispose = <StreamSubscription>[];
  StreamSubscription<ably.Message?>? _channelMessageSubscription;
  ably.Message? channelMessage;
  StreamSubscription<ably.PresenceMessage?>?
      _channelPresenceMessageSubscription;
  ably.PresenceMessage? channelPresenceMessage;
  List<ably.PresenceMessage>? _realtimePresenceMembers;
  late final PushNotificationService _pushNotificationService =
      PushNotificationService();
  bool isIOSSimulator = false;

  //Storing different message types here to be publishable
  List<dynamic> messagesToPublish = [
    null,
    'A simple panda...',
    {
      'I am': null,
      'and': {
        'also': 'nested',
        'too': {'deep': true}
      }
    },
    [
      42,
      {'are': 'you'},
      'ok?',
      false,
      {
        'I am': null,
        'and': {
          'also': 'nested',
          'too': {'deep': true}
        }
      }
    ]
  ];

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  @override
  void dispose() {
    // This dispose would not be effective in this example as this is
    // a single view but subscriptions must be disposed when listeners are
    // implemented in the actual application
    //
    // See: https://api.flutter.dev/flutter/widgets/State/dispose.html
    for (final s in _subscriptionsToDispose) {
      s.cancel();
    }
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> asyncInitState() async {
    String platformVersion;
    String ablyVersion;

    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      setState(() {
        isIOSSimulator = !iosInfo.isPhysicalDevice;
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    createAblyRealtime();
    await createAblyRest();
  }

  Future<void> createAblyRest() async {
    final clientOptions = ably.ClientOptions.fromKey(_apiKey)
      ..clientId = Constants.clientId
      ..logLevel = ably.LogLevel.verbose
      ..logHandler = ({msg, exception}) {
        print('Custom logger :: $msg $exception');
      };

    try {
      _rest = ably.Rest(options: clientOptions);
      await encryptedMessagingService!.setRestClient(_rest!);
      _pushNotificationService.setRestClient(_rest!);
      setState(() {});
    } on Exception catch (error) {
      print('Error creating Ably Rest: $error');
      rethrow;
    }
  }

  void createAblyRealtime() {
    final clientOptions = ably.ClientOptions.fromKey(_apiKey)
      ..clientId = Constants.clientId
      ..logLevel = ably.LogLevel.verbose
      ..autoConnect = false
      ..logHandler = ({msg, exception}) {
        print('Custom logger :: $msg $exception');
      };

    try {
      final realtime = ably.Realtime(options: clientOptions);
      listenRealtimeConnection(realtime);
      final channel = realtime.channels.get(defaultChannel);
      listenRealtimeChannel(channel);
      encryptedMessagingService = EncryptedMessagingService(realtime);
      _pushNotificationService.setRealtimeClient(realtime);
      setState(() {
        _realtime = realtime;
      });
    } on Exception catch (error) {
      print('Error creating Ably Realtime: $error');
      rethrow;
    }
  }

  void listenRealtimeConnection(ably.Realtime realtime) {
    final alphaSubscription =
        realtime.connection.on().listen((stateChange) async {
      if (stateChange.current == ably.ConnectionState.failed) {
        logAndDisplayError(stateChange.reason);
      }
      print('${DateTime.now()}:'
          ' ConnectionStateChange event: ${stateChange.event}'
          '\nReason: ${stateChange.reason}');
      setState(() {
        _realtimeConnectionState = stateChange.current;
      });
    });
    _subscriptionsToDispose.add(alphaSubscription);
  }

  void listenRealtimeChannel(ably.RealtimeChannel channel) {
    final _channelStateChangeSubscription = channel.on().listen((stateChange) {
      print('ChannelStateChange: ${stateChange.current}'
          '\nReason: ${stateChange.reason}');
      setState(() {
        _realtimeChannelState = channel.state;
      });
    });
    _subscriptionsToDispose.add(_channelStateChangeSubscription);
  }

  Widget createRTConnectButton() => TextButton(
        onPressed: (_realtime == null) ? null : _realtime!.connect,
        child: const Text('Connect'),
      );

  Widget createRTCloseButton() => TextButton(
        onPressed: (_realtimeConnectionState == ably.ConnectionState.connected)
            ? _realtime!.close
            : null,
        child: const Text('Disconnect'),
      );

  Widget createChannelAttachButton() => TextButton(
        onPressed:
            (_realtimeConnectionState == ably.ConnectionState.connected &&
                    _realtimeChannelState != ably.ChannelState.attached)
                ? () async {
                    final channel = _realtime!.channels.get(defaultChannel);
                    print('Attaching to channel ${channel.name}.'
                        ' Current state ${channel.state}.');
                    setState(() {
                      _realtimeChannelState = channel.state;
                    });
                    try {
                      await channel.attach();
                    } on ably.AblyException catch (e) {
                      print('Unable to attach to channel: ${e.errorInfo}');
                    }
                  }
                : null,
        child: const Text('Attach'),
      );

  Widget createChannelDetachButton() => TextButton(
        onPressed: (_realtimeChannelState == ably.ChannelState.attached)
            ? () {
                _realtime!.channels.get(defaultChannel).detach();
              }
            : null,
        child: const Text('Detach'),
      );

  Widget createChannelSubscribeButton() => TextButton(
        onPressed: (_realtimeChannelState == ably.ChannelState.attached &&
                _channelMessageSubscription == null)
            ? () {
                final channel = _realtime!.channels.get(defaultChannel);
                final messageStream =
                    channel.subscribe(names: ['message-data', 'Hello']);
                _channelMessageSubscription = messageStream.listen((message) {
                  print('Channel message received: $message\n'
                      '\tisNull: ${message.data == null}\n'
                      '\tisString ${message.data is String}\n'
                      '\tisMap ${message.data is Map}\n'
                      '\tisList ${message.data is List}\n');
                  setState(() {
                    channelMessage = message;
                  });
                });
                print('Channel messages subscribed');
                setState(() {});
                _subscriptionsToDispose.add(_channelMessageSubscription!);
              }
            : null,
        child: const Text('Subscribe'),
      );

  Widget createChannelUnSubscribeButton() => TextButton(
        onPressed: (_channelMessageSubscription != null)
            ? () async {
                await _channelMessageSubscription!.cancel();
                print('Channel messages unsubscribed');
                setState(() {
                  _channelMessageSubscription = null;
                });
              }
            : null,
        child: const Text('Unsubscribe'),
      );

  int typeCounter = 0;
  int realtimePubCounter = 0;

  Widget createChannelPublishButton() => TextButton(
        onPressed: (_realtimeChannelState == ably.ChannelState.attached)
            ? () async {
                final data = messagesToPublish[
                    (realtimePubCounter++ % messagesToPublish.length)];
                final m = ably.Message(
                    name: 'Message $realtimePubCounter', data: data);
                try {
                  switch (typeCounter % 3) {
                    case 0:
                      await _realtime!.channels.get(defaultChannel).publish(
                          name: 'Message $realtimePubCounter', data: data);
                      break;
                    case 1:
                      await _realtime!.channels
                          .get(defaultChannel)
                          .publish(message: m);
                      break;
                    case 2:
                      await _realtime!.channels
                          .get(defaultChannel)
                          .publish(messages: [m, m]);
                  }
                  if (realtimePubCounter != 0 &&
                      realtimePubCounter % messagesToPublish.length == 0) {
                    typeCounter++;
                  }
                  setState(() {});
                } on ably.AblyException catch (e) {
                  print(e);
                }
              }
            : null,
        child: const Text(
          'Publish',
        ),
      );

  int msgCounter = 1;

  Widget sendRestMessage() {
    final messageName = 'Message $msgCounter';
    return TextButton(
      onPressed: (_rest == null)
          ? null
          : () async {
              try {
                await _rest!.channels.get(defaultChannel).publish(
                    name: messageName,
                    data: 'Some data for Message $msgCounter');
                setState(() {
                  ++msgCounter;
                });
              } on ably.AblyException catch (e) {
                print('Rest message sending failed:: $e :: ${e.errorInfo}');
              }
            },
      child: Text('Publish message: "$messageName"'),
    );
  }

  Widget releaseRestChannel() => TextButton(
        onPressed: (_rest == null)
            ? null
            : () => _rest!.channels.release(defaultChannel),
        child: const Text('Release Rest channel'),
      );

  Widget createChannelPresenceSubscribeButton() => TextButton(
        onPressed: (_realtimeChannelState == ably.ChannelState.attached &&
                _channelPresenceMessageSubscription == null)
            ? () {
                final channel = _realtime!.channels.get(defaultChannel);
                final presenceMessageStream = channel.presence.subscribe();
                _channelPresenceMessageSubscription =
                    presenceMessageStream.listen((presenceMessage) {
                  print('Channel presence message received: $presenceMessage');
                  setState(() {
                    channelPresenceMessage = presenceMessage;
                  });
                });
                setState(() {});
                print('Channel presence messages subscribed');
                _subscriptionsToDispose
                    .add(_channelPresenceMessageSubscription!);
              }
            : null,
        child: const Text('Subscribe'),
      );

  Widget createChannelPresenceUnSubscribeButton() => TextButton(
        onPressed: (_channelPresenceMessageSubscription != null)
            ? () async {
                await _channelPresenceMessageSubscription!.cancel();
                print('Channel presence messages unsubscribed');
                setState(() {
                  _channelPresenceMessageSubscription = null;
                });
              }
            : null,
        child: const Text('Unsubscribe'),
      );

  Widget getRealtimeChannelPresence() => TextButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                _realtimePresenceMembers = await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .get(ably.RealtimePresenceParams());
                setState(() {});
              },
        child: const Text('Get Realtime presence members'),
      );

  Widget releaseRealtimeChannel() => TextButton(
        onPressed: (_realtime == null)
            ? null
            : () => _realtime!.channels.release(defaultChannel),
        child: const Text('Release'),
      );

  final List _presenceData = [
    null,
    1,
    'hello',
    {'a': 'b'},
    [
      1,
      'ably',
      null,
      {'a': 'b'}
    ],
    {
      'c': ['a', 'b']
    },
  ];

  int _presenceDataIncrementer = 0;

  Object get _nextPresenceData =>
      _presenceData[_presenceDataIncrementer++ % _presenceData.length]
          .toString();

  Widget enterRealtimePresence() => TextButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .enter(_nextPresenceData);
                setState(() {});
              },
        child: const Text('Enter'),
      );

  Widget updateRealtimePresence() => TextButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .updateClient(Constants.clientId, _nextPresenceData);
                setState(() {});
              },
        child: const Text('Update'),
      );

  Widget leaveRealtimePresence() => TextButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .leave(_nextPresenceData);
                setState(() {});
              },
        child: const Text('Leave'),
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Ably Plugin Example App'),
          ),
          body: Center(
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                children: [
                  SystemDetailsSliver(_apiKey),
                  const Divider(),
                  const Text(
                    'Realtime',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Connection State: $_realtimeConnectionState'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: createRTConnectButton(),
                      ),
                      Expanded(
                        child: createRTCloseButton(),
                      )
                    ],
                  ),
                  const Text(
                    'Channel',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('Channel State: $_realtimeChannelState'),
                  Row(
                    children: <Widget>[
                      Expanded(child: createChannelAttachButton()),
                      Expanded(child: createChannelDetachButton()),
                      Expanded(child: releaseRealtimeChannel()),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: createChannelSubscribeButton()),
                      Expanded(child: createChannelPublishButton()),
                      Expanded(child: createChannelUnSubscribeButton()),
                    ],
                  ),
                  TextRow('Latest message received',
                      channelMessage?.data.toString()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextRow('Next message to be published:', null),
                      TextRow('  Name', 'Message $realtimePubCounter'),
                      TextRow(
                          '  Data',
                          messagesToPublish[
                                  realtimePubCounter % messagesToPublish.length]
                              .toString()),
                    ],
                  ),
                  PaginatedResultViewer<ably.Message>(
                      title: 'History',
                      query: () =>
                          _realtime!.channels.get(defaultChannel).history(
                                ably.RealtimeHistoryParams(
                                  limit: 10,
                                  untilAttach: true,
                                ),
                              ),
                      builder: (context, message, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextRow('Name', message.name),
                              TextRow('Data', message.data.toString()),
                            ],
                          )),
                  const Text(
                    'Presence',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: createChannelPresenceSubscribeButton()),
                      Expanded(child: createChannelPresenceUnSubscribeButton()),
                    ],
                  ),
                  Text(
                    'Presence Message from channel:'
                    ' ${channelPresenceMessage?.data}',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: enterRealtimePresence(),
                      ),
                      Expanded(
                        child: updateRealtimePresence(),
                      ),
                      Expanded(
                        child: leaveRealtimePresence(),
                      ),
                    ],
                  ),
                  getRealtimeChannelPresence(),
                  ..._realtimePresenceMembers
                          ?.map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
                          .toList() ??
                      [],
                  PaginatedResultViewer<ably.PresenceMessage>(
                      title: 'Presence history',
                      query: () => _realtime!.channels
                          .get(defaultChannel)
                          .presence
                          .history(ably.RealtimeHistoryParams(limit: 10)),
                      builder: (context, message, _) => TextRow('clientId',
                          '${message.id}:${message.clientId}:${message.data}')),
                  const Divider(),
                  const Text(
                    'Rest',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  sendRestMessage(),
                  releaseRestChannel(),
                  PaginatedResultViewer<ably.Message>(
                      title: 'History',
                      query: () => _rest!.channels
                          .get(Constants.channelName)
                          .history(ably.RestHistoryParams(
                            direction: 'forwards',
                            limit: 10,
                          )),
                      builder: (context, message, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextRow('Name', message.name),
                              TextRow('Data', message.data.toString()),
                            ],
                          )),
                  PaginatedResultViewer<ably.PresenceMessage>(
                      title: 'Presence members',
                      query: () => _rest!.channels
                          .get(defaultChannel)
                          .presence
                          .get(ably.RestPresenceParams(limit: 10)),
                      builder: (context, message, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextRow('Message ID', '${message.id}'),
                              TextRow(
                                  'Message client ID', '${message.clientId}'),
                              TextRow('Message data', '${message.data}'),
                            ],
                          )),
                  PaginatedResultViewer<ably.PresenceMessage>(
                      title: 'Presence history',
                      query: () => _rest!.channels
                          .get(defaultChannel)
                          .presence
                          .history(ably.RestHistoryParams(limit: 10)),
                      builder: (context, message, _) => TextRow('Message name',
                          '${message.id}:${message.clientId}:${message.data}')),
                  const Divider(),
                  MessageEncryptionSliver(encryptedMessagingService),
                  const Divider(),
                  PushNotificationsSliver(
                    _pushNotificationService,
                    isIOSSimulator: isIOSSimulator,
                  )
                ]),
          ),
        ),
      );
}
