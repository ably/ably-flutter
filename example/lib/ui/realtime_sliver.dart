import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/service/ably_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'realtime_presence_sliver.dart';

class RealtimeSliver extends StatefulWidget {
  const RealtimeSliver(AblyService ablyService, {Key? key}) : super(key: key);

  @override
  _RealtimeSliverState createState() => _RealtimeSliverState();
}

class _RealtimeSliverState extends State<RealtimeSliver> {
  ably.Message? channelMessage;
  ably.PaginatedResult<ably.Message>? _realtimeHistory;

  Widget getRealtimeChannelHistory() => getPageNavigator<ably.Message>(
      name: 'Realtime history',
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

  Widget createChannelAttachButton() => FlatButton(
    padding: EdgeInsets.zero,
    onPressed: (_realtimeConnectionState == ably.ConnectionState.connected)
        ? () async {
      final channel = _realtime!.channels.get(defaultChannel);
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

  Widget createChannelDetachButton() => FlatButton(
    padding: EdgeInsets.zero,
    onPressed: (_realtimeChannelState == ably.ChannelState.attached)
        ? () {
      final channel = _realtime!.channels.get(defaultChannel);
      print('Detaching from channel ${channel.name}.'
          ' Current state ${channel.state}.');
      channel.detach();
      print('Detached');
    }
        : null,
    child: const Text('Detach from channel'),
  );

  Widget createChannelSubscribeButton() => FlatButton(
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
      _subscriptionsToDispose.add(_channelMessageSubscription!);
    }
        : null,
    child: const Text('Subscribe'),
  );

  Widget createChannelUnSubscribeButton() => FlatButton(
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

  Widget createChannelPublishButton() => FlatButton(
    onPressed: (_realtimeChannelState == ably.ChannelState.attached)
        ? () async {
      print('Sending rest message...');
      final data = messagesToPublish[
      (realtimePubCounter++ % messagesToPublish.length)];
      final m = ably.Message(name: 'Hello', data: data);
      try {
        switch (typeCounter % 3) {
          case 0:
            await _realtime!.channels
                .get(defaultChannel)
                .publish(name: 'Hello', data: data);
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
        print('Realtime message sent.');
        setState(() {});
      } on ably.AblyException catch (e) {
        print(e);
      }
    }
        : null,
    color: Colors.yellow,
    child: Text(
      'Publish: '
          '${messagesToPublish[realtimePubCounter % messagesToPublish.length]}',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text(
        'Realtime',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      createRealtimeButton(),
      Text(
        'Realtime:'
        ' ${_realtime?.toString() ?? 'Realtime not created yet.'}',
      ),
      Text('Connection State: $_realtimeConnectionState'),
      Text('Channel State: $_realtimeChannelState'),
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
      const Text(
        'Channel Messages',
        style: TextStyle(fontSize: 20),
      ),
      Text('Message from channel: ${channelMessage?.data ?? '-'}'),
      createChannelPublishButton(),
      getRealtimeChannelHistory(),
      ..._realtimeHistory?.items
              .map((m) => Text('${m.name}:${m.data?.toString()}'))
              .toList() ??
          [],
      RealtimePresenceSliver(),

    ]);
  }
}
