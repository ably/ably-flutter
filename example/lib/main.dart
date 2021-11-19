import 'dart:async';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/encrypted_messaging_service.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_handlers.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:ably_flutter_example/ui/message_encryption/message_encryption_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_sliver.dart';
import 'package:ably_flutter_example/ui/realtime_sliver.dart';
import 'package:ably_flutter_example/ui/system_details_sliver.dart';
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
  ably.ChannelState? _realtimeChannelState;
  final _subscriptionsToDispose = <StreamSubscription>[];
  ably.Message? channelMessage;
  ably.PaginatedResult<ably.Message>? _restHistory;
  ably.PaginatedResult<ably.Message>? _realtimeHistory;
  ably.PaginatedResult<ably.PresenceMessage>? _restPresenceMembers;
  ably.PaginatedResult<ably.PresenceMessage>? _restPresenceHistory;
  StreamSubscription<ably.PresenceMessage?>?
      _channelPresenceMessageSubscription;
  ably.PresenceMessage? channelPresenceMessage;
  List<ably.PresenceMessage>? _realtimePresenceMembers;
  ably.PaginatedResult<ably.PresenceMessage>? _realtimePresenceHistory;
  late final PushNotificationService _pushNotificationService =
      PushNotificationService();
  late final AblyService _ablyService = AblyService(_apiKey);
  bool isIOSSimulator = false;

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
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      setState(() {
        isIOSSimulator = !iosInfo.isPhysicalDevice;
      });
    }

    _pushNotificationService.setRealtimeClient(_realtime!);
    _pushNotificationService.setRestClient(_rest!);
  }

  int msgCounter = 1;

  Widget sendRestMessage() => FlatButton(
        onPressed: (_rest == null)
            ? null
            : () async {
                print('Sending rest message');
                try {
                  await _rest!.channels
                      .get(defaultChannel)
                      .publish(name: 'Hello', data: 'Flutter $msgCounter');
                  print('Rest message sent.');
                  setState(() {
                    ++msgCounter;
                  });
                } on ably.AblyException catch (e) {
                  print('Rest message sending failed:: $e :: ${e.errorInfo}');
                }
              },
        color: Colors.yellow,
        child: const Text('Publish'),
      );

  Widget getPageNavigator<T>({
    required bool enabled,
    required String name,
    required Future<ably.PaginatedResult<T>> Function() query,
    required Function(ably.PaginatedResult<T> result) onUpdate,
    ably.PaginatedResult<T>? page,
  }) =>
      FlatButton(
        onPressed: !enabled
            ? null
            : () async {
                final next = page?.hasNext() ?? false;
                print('$name: getting ${next ? 'next' : 'first'} page');
                try {
                  if (page == null || page.items.isEmpty) {
                    onUpdate(await query());
                  } else if (next) {
                    onUpdate(await page.next());
                  } else {
                    onUpdate(await page.first());
                  }
                } on ably.AblyException catch (e) {
                  print('failed to get $name:: $e :: ${e.errorInfo}');
                }
              },
        onLongPress: !enabled
            ? null
            : () async {
                onUpdate(await query());
              },
        color: Colors.yellow,
        child: Text('Get $name'),
      );

  Widget getRestChannelHistory() => getPageNavigator<ably.Message>(
      name: 'Rest history',
      enabled: _rest != null,
      page: _restHistory,
      query: () async =>
          _rest!.channels.get(defaultChannel).history(ably.RestHistoryParams(
                direction: 'forwards',
                limit: 10,
              )),
      onUpdate: (result) {
        setState(() {
          _restHistory = result;
        });
      });

  Widget getRestChannelPresence() => getPageNavigator<ably.PresenceMessage>(
      name: 'Rest presence members',
      enabled: _rest != null,
      page: _restPresenceMembers,
      query: () async => _rest!.channels
          .get(defaultChannel)
          .presence
          .get(ably.RestPresenceParams(limit: 10)),
      onUpdate: (result) {
        setState(() {
          _restPresenceMembers = result;
        });
      });

  Widget getRestChannelPresenceHistory() =>
      getPageNavigator<ably.PresenceMessage>(
          name: 'Rest presence history',
          enabled: _rest != null,
          page: _restPresenceHistory,
          query: () async => _rest!.channels
              .get(defaultChannel)
              .presence
              .history(ably.RestHistoryParams(limit: 10)),
          onUpdate: (result) {
            setState(() {
              _restPresenceHistory = result;
            });
          });

  Widget releaseRestChannel() => FlatButton(
        color: Colors.deepOrangeAccent[100],
        onPressed: (_rest == null)
            ? null
            : () => _rest!.channels.release(defaultChannel),
        child: const Text('Release Rest channel'),
      );

  Widget getRealtimeChannelHistory() => getPageNavigator<ably.Message>(
      name: 'Realtime history',
      enabled: _realtime != null,
      page: _realtimeHistory,
      query: () async => _realtime!.channels.get(defaultChannel).history(
            ably.RealtimeHistoryParams(
              limit: 10,
              untilAttach: true,
            ),
          ),
      onUpdate: (result) {
        setState(() {
          _realtimeHistory = result;
        });
      });

  Widget createChannelPresenceSubscribeButton() => FlatButton(
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

  Widget createChannelPresenceUnSubscribeButton() => FlatButton(
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

  Widget getRealtimeChannelPresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                _realtimePresenceMembers = await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .get(ably.RealtimePresenceParams());
                setState(() {});
              },
        color: Colors.yellow,
        child: const Text('Get Realtime presence members'),
      );

  Widget getRealtimeChannelPresenceHistory() =>
      getPageNavigator<ably.PresenceMessage>(
          name: 'Realtime presence history',
          enabled: _realtime != null,
          page: _realtimePresenceHistory,
          query: () async => _realtime!.channels
              .get(defaultChannel)
              .presence
              .history(ably.RealtimeHistoryParams(limit: 10)),
          onUpdate: (result) {
            setState(() {
              _realtimePresenceHistory = result;
            });
          });

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

  Object? get _currentPresenceData => (_presenceDataIncrementer == 0)
      ? null
      : _presenceData[(_presenceDataIncrementer - 1) % _presenceData.length];

  Widget enterRealtimePresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .enter(_nextPresenceData);
                setState(() {});
              },
        color: Colors.yellow,
        child: const Text('Enter'),
      );

  Widget updateRealtimePresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .updateClient(Constants.clientId, _nextPresenceData);
                setState(() {});
              },
        color: Colors.yellow,
        child: const Text('Update'),
      );

  Widget leaveRealtimePresence() => FlatButton(
        onPressed: (_realtime == null)
            ? null
            : () async {
                await _realtime!.channels
                    .get(defaultChannel)
                    .presence
                    .leave(_nextPresenceData);
                setState(() {});
              },
        color: Colors.yellow,
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
                  RealtimeSliver(_ablyService),
                  const Divider(),
                  const Text(
                    'Rest',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  sendRestMessage(),
                  Text(
                    'Rest: press this button to publish a new message with'
                    ' data "Flutter $msgCounter"',
                  ),
                  getRestChannelHistory(),
                  ..._restHistory?.items
                          .map((m) => Text('${m.name}:${m.data?.toString()}'))
                          .toList() ??
                      [],
                  getRestChannelPresence(),
                  ..._restPresenceMembers?.items
                          .map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
                          .toList() ??
                      [],
                  getRestChannelPresenceHistory(),
                  ..._restPresenceHistory?.items
                          .map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
                          .toList() ??
                      [],
                  releaseRestChannel(),
                  const Divider(),
                  MessageEncryptionSliver(_ablyService.encryptedMessagingService),
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
