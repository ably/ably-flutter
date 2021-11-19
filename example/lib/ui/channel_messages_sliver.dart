import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/ui/bool_stream_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'ably_service.dart';

class ChannelMessagesSliver extends HookWidget {
  final ably.RealtimeChannel channel;
  final ValueNotifier<ably.Message?> latestChannelMessage;
  final ValueNotifier<ably.ChannelState> channelState;

  ChannelMessagesSliver(this.channel, this.channelState,
      this.latestChannelMessage);

  @override
  Widget build(BuildContext context) => Column(
      children: [
        const Text(
          'Channel Messages',
          style: TextStyle(fontSize: 20),
        ),
        Text(
            'Message from channel: ${latestChannelMessage.value?.data ?? '-'}'),
        TextButton(
            onPressed: channelState.value == ably.ChannelState.attached ? () {
              channel.publish(message: ExampleMessages.message);
            } : null, child: const Text('Publish single message')),
        TextButton(
          onPressed:channelState.value == ably.ChannelState.attached ? () {
            channel.publish(messages: ExampleMessages.messages);
          } : null,
          child: const Text('Publish multiple messages'),
        ),
        getRealtimeChannelHistory(),
        ..._realtimeHistory?.items
            .map((m) => Text('${m.name}:${m.data?.toString()}'))
            .toList() ??
            [],
      ]
      ,
    );
}
