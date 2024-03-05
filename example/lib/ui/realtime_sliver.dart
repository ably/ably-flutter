import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:ably_flutter_example/ui/paginated_result_viewer.dart';
import 'package:ably_flutter_example/ui/realtime_presence_sliver.dart';
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:ably_flutter_example/ui/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class RealtimeSliver extends HookWidget {
  final AblyService ablyService;
  final ably.Realtime realtime;
  late ably.RealtimeChannel channel;
  List<StreamSubscription<dynamic>> _subscriptions = [];

  RealtimeSliver(this.ablyService, {Key? key})
      : realtime = ablyService.realtime,
        super(key: key) {
    channel = realtime.channels.get(Constants.channelName);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions = [];
  }

  Widget buildConnectButton() => TextButton(
        onPressed: realtime.connect,
        child: const Text('Connect'),
      );

  Widget buildDisconnectButton(ably.ConnectionState state) => TextButton(
        onPressed:
            (state == ably.ConnectionState.connected) ? realtime.close : null,
        child: const Text('Disconnect'),
      );

  Widget buildChannelAttachButton(ably.ConnectionState connectionState,
          ably.ChannelState channelState) =>
      TextButton(
        onPressed: (connectionState == ably.ConnectionState.connected &&
                channelState != ably.ChannelState.attached)
            ? () async {
                try {
                  await channel.attach();
                } on ably.AblyException catch (e) {
                  print('Unable to attach to channel: ${e.errorInfo}');
                }
              }
            : null,
        child: const Text('Attach'),
      );

  Widget buildChannelDetachButton(ably.ChannelState channelState) => TextButton(
        onPressed: (channelState == ably.ChannelState.attached)
            ? channel.detach
            : null,
        child: const Text('Detach'),
      );

  Widget buildChannelSubscribeButton(
          ably.ChannelState channelState,
          ValueNotifier<ably.Message?> latestMessage,
          ValueNotifier<StreamSubscription<ably.Message>?>
              channelSubscription) =>
      TextButton(
        onPressed: (channelState == ably.ChannelState.attached &&
                channelSubscription.value == null)
            ? () {
                final subscription = channel.subscribe().listen((message) {
                  latestMessage.value = message;
                });
                channelSubscription.value = subscription;
                _subscriptions.add(subscription);
              }
            : null,
        child: const Text('Subscribe'),
      );

  Widget buildChannelUnsubscribeButton(
          ValueNotifier<StreamSubscription<dynamic>?> channelSubscription) =>
      TextButton(
        onPressed: (channelSubscription.value != null)
            ? () async {
                await channelSubscription.value!.cancel();
                channelSubscription.value = null;
              }
            : null,
        child: const Text('Unsubscribe'),
      );

  int typeCounter = 0;
  int realtimePubCounter = 0;

  Widget buildChannelPublishButton(ably.ChannelState channelState) =>
      TextButton(
        onPressed: (channelState == ably.ChannelState.attached)
            ? () async {
                final data = _messagesToPublish[
                    (realtimePubCounter++ % _messagesToPublish.length)];
                final m = ably.Message(
                    name: 'Message $realtimePubCounter', data: data);
                try {
                  switch (typeCounter % 3) {
                    case 0:
                      await channel.publish(
                          name: 'Message $realtimePubCounter', data: data);
                      break;
                    case 1:
                      await channel.publish(message: m);
                      break;
                    case 2:
                      await channel.publish(messages: [m, m]);
                  }
                  if (realtimePubCounter != 0 &&
                      realtimePubCounter % _messagesToPublish.length == 0) {
                    typeCounter++;
                  }
                } on ably.AblyException catch (e) {
                  print(e);
                }
              }
            : null,
        child: const Text(
          'Publish',
        ),
      );

  Widget buildReleaseRealtimeChannelButton(
    ValueNotifier<ably.ConnectionState> connectionState,
    ValueNotifier<ably.ChannelState> channelState,
    ValueNotifier<String?> connectionId,
    ValueNotifier<String?> recoveryKey,
  ) =>
      TextButton(
        onPressed: () async {
          await channel.detach();
          realtime.channels.release(Constants.channelName);
          channel = realtime.channels.get(Constants.channelName);
          setupListeners(
              connectionState, channelState, connectionId, recoveryKey);
        },
        child: const Text('Release'),
      );

  Widget buildEncryptionSwitch(ValueNotifier<bool> isEnabled) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Enable encryption',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Switch(
            onChanged: (switchedOn) async {
              isEnabled.value = switchedOn;
              if (switchedOn) {
                await channel.setOptions(
                  await ably.RealtimeChannelOptions.withCipherKey(
                    keyFromPassword(
                      Constants.examplePasswordForEncryptedChannel,
                    ),
                  ),
                );
              } else {
                await channel.setOptions(const ably.RealtimeChannelOptions());
              }
            },
            value: isEnabled.value,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final connectionState =
        useState<ably.ConnectionState>(realtime.connection.state);
    final connectionId = useState<String?>(realtime.connection.id);
    final recoveryKey = useState<String?>('');
    final channelState = useState<ably.ChannelState>(channel.state);
    final latestMessage = useState<ably.Message?>(null);
    final channelSubscription =
        useState<StreamSubscription<ably.Message>?>(null);
    final realtimeTime = useState<DateTime?>(null);
    final useEncryption = useState(false);

    useEffect(() {
      realtime.time().then((value) => realtimeTime.value = value);
      setupListeners(connectionState, channelState, connectionId, recoveryKey);
      return dispose;
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Realtime',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text('Realtime time: ${realtimeTime.value}'),
        Text('Connection State: ${connectionState.value}'),
        Text('Connection Id: ${connectionId.value ?? '-'}'),
        Text('Connection Recovery Key: ${recoveryKey.value ?? '-'}'),
        buildEncryptionSwitch(useEncryption),
        Row(
          children: <Widget>[
            Expanded(
              child: buildConnectButton(),
            ),
            Expanded(
              child: buildDisconnectButton(connectionState.value),
            )
          ],
        ),
        const Text(
          'Channel',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text('Channel State: ${channelState.value}'),
        Row(
          children: <Widget>[
            Expanded(
                child: buildChannelAttachButton(
                    connectionState.value, channelState.value)),
            Expanded(child: buildChannelDetachButton(channelState.value)),
            Expanded(
                child: buildReleaseRealtimeChannelButton(
                    connectionState, channelState, connectionId, recoveryKey)),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: buildChannelSubscribeButton(
                    channelState.value, latestMessage, channelSubscription)),
            Expanded(child: buildChannelPublishButton(channelState.value)),
            Expanded(child: buildChannelUnsubscribeButton(channelSubscription)),
          ],
        ),
        TextRow(
            'Latest message received', latestMessage.value?.data.toString()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextRow('Next message to be published:', null),
            TextRow('  Name', 'Message $realtimePubCounter'),
            TextRow(
                '  Data',
                _messagesToPublish[
                        realtimePubCounter % _messagesToPublish.length]
                    .toString()),
          ],
        ),
        RealtimePresenceSliver(
          realtime: realtime,
          channel: channel,
        ),
        PaginatedResultViewer<ably.Message>(
            title: 'History',
            subtitle: Column(
              children: const [
                TextRow(
                    'Hint',
                    'Use realtime history as a way to get messages that were'
                        ' published before you are attached to the channel.'),
                TextRow(
                    'Warning',
                    'If you are already attached to the channel, you must'
                        ' detach and re-attach to get the latest messages '
                        'published on the channel to get history whilst '
                        'connected to a realtime channel, use '
                        'RestChannel.history instead.'),
              ],
            ),
            query: () => channel.history(
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
      ],
    );
  }

  void setupListeners(
      ValueNotifier<ably.ConnectionState> connectionState,
      ValueNotifier<ably.ChannelState> channelState,
      ValueNotifier<String?> connectionId,
      ValueNotifier<String?> recoveryKey) {
    dispose();
    final connectionSubscription =
        realtime.connection.on().listen((connectionStateChange) {
      if (connectionStateChange.current == ably.ConnectionState.failed) {
        logAndDisplayError(connectionStateChange.reason);
      }
      connectionState.value = connectionStateChange.current;
      connectionId.value = realtime.connection.id;
      realtime.connection
          .createRecoveryKey()
          .then((value) => {recoveryKey.value = value});
      print('${DateTime.now()}:'
          ' ConnectionStateChange event: ${connectionStateChange.event}'
          '\nReason: ${connectionStateChange.reason}');
    });
    _subscriptions.add(connectionSubscription);
    final channelSubscription = channel.on().listen((stateChange) {
      channelState.value = channel.state;
    });
    _subscriptions.add(channelSubscription);
  }
}

List<dynamic> _messagesToPublish = [
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
