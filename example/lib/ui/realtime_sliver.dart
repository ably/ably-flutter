import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:ably_flutter_example/ui/channel_messages_sliver.dart';
import 'package:ably_flutter_example/ui/realtime_presence_sliver.dart';
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:ably_flutter_example/ui/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RealtimeSliver extends HookWidget {
  final AblyService ablyService;
  late final ably.Realtime realtime;
  late final ably.RealtimeChannel channel;

  RealtimeSliver(this.ablyService, {Key? key}) : super(key: key) {
    realtime = ablyService.realtime;
    channel = realtime.channels.get(Constants.channelName);
  }

  @override
  Widget build(BuildContext context) {
    final connectionState =
        useState<ably.ConnectionState>(realtime.connection.state);
    final channelState = useState<ably.ChannelState>(channel.state);
    final latestChannelMessage = useState<ably.Message?>(null);
    final channelSubscription = useState<StreamSubscription?>(null);

    useEffect(() {
      final realtimeConnectionSubscription = realtime.connection.on().listen((connectionStateChange) {
        if (connectionStateChange.current == ably.ConnectionState.failed) {
          logAndDisplayError(connectionStateChange.reason);
        }
        connectionState.value = connectionStateChange.current;
        print('${DateTime.now()}:'
            ' ConnectionStateChange event: ${connectionStateChange.event}'
            '\nReason: ${connectionStateChange.reason}');
      });
      final channelSubscription = channel.on().listen((stateChange) {
        channelState.value = channel.state;
      });
      // TODO implement clean up.
      // subscriptions.add(channelSubscription);
      // subscriptions.add(realtimeConnectionSubscription);
    }, []);

    Widget buildChannelAttachButton() => TextButton(
          onPressed: (connectionState.value == ably.ConnectionState.connected)
              ? () async {
                  print('Attaching to channel ${channel.name}.'
                      ' Current state ${channel.state}.');
                  try {
                    await channel.attach();
                  } on ably.AblyException catch (e) {
                    print('Unable to attach to channel: ${e.errorInfo}');
                  }
                }
              : null,
          child: const Text('Attach to Channel'),
        );

    Widget buildChannelDetachButton() => TextButton(
          onPressed: (channelState.value == ably.ChannelState.attached)
              ? () {
                  print('Detaching from channel ${channel.name}.'
                      ' Current state ${channel.state}.');
                  channel.detach();
                  print('Detached');
                }
              : null,
          child: const Text('Detach from channel'),
        );

    Widget buildChannelSubscribeButton() => TextButton(
          onPressed: (channelState.value == ably.ChannelState.attached &&
                  channelSubscription.value == null)
              ? () {
                  final messageStream =
                      channel.subscribe(names: ['message-data', 'Hello']);
                  channelSubscription.value = messageStream.listen((message) {
                    print('Channel message received: $message\n'
                        '\tisNull: ${message.data == null}\n'
                        '\tisString ${message.data is String}\n'
                        '\tisMap ${message.data is Map}\n'
                        '\tisList ${message.data is List}\n');
                    latestChannelMessage.value = message;
                  });
                  // TODO dispose
                  // _subscriptionsToDispose.add(_channelMessageSubscription!);
                }
              : null,
          child: const Text('Subscribe'),
        );

    Widget buildChannelUnsubscribeButton() => TextButton(
          onPressed: (channelSubscription.value != null)
              ? () async {
                  await channelSubscription.value!.cancel();
                  channelSubscription.value = null;
                }
              : null,
          child: const Text('Unsubscribe'),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Realtime',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        TextRow('Connection State', connectionState.toString()),
        TextRow('Channel State', channelState.toString()),
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: realtime.connect,
                child: const Text('Connect'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: realtime.close,
                child: const Text('Close Connection'),
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: buildChannelAttachButton()),
            Expanded(child: buildChannelDetachButton()),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(child: buildChannelSubscribeButton()),
            Expanded(child: buildChannelUnsubscribeButton()),
          ],
        ),
        ChannelMessagesSliver(channel, channelState, latestChannelMessage),
        RealtimePresenceSliver(),
        TextButton(
          onPressed: () => realtime.channels.release(channel.name),
          child: const Text('Release channel'),
        ),
      ],
    );
  }
}
