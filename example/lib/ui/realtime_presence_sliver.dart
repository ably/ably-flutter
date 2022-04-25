import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/ui/paginated_result_viewer.dart';
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// ignore: must_be_immutable
class RealtimePresenceSliver extends HookWidget {
  final ably.Realtime realtime;
  final ably.RealtimeChannel channel;
  final List<StreamSubscription<ably.PresenceMessage?>> _subscriptions = [];

  RealtimePresenceSliver({
    required this.realtime,
    required this.channel,
    Key? key,
  }) : super(key: key);

  Widget createChannelPresenceSubscribeButton(
    ValueNotifier<ably.PresenceMessage?> latestMessage,
    ably.ChannelState? channelState,
    ValueNotifier<StreamSubscription<ably.PresenceMessage?>?>
        presenceSubscription,
  ) =>
      TextButton(
        onPressed: (channelState == ably.ChannelState.attached &&
                presenceSubscription.value == null)
            ? () {
                final presenceMessageStream = channel.presence.subscribe();
                final subscription =
                    presenceMessageStream.listen((presenceMessage) {
                  latestMessage.value = presenceMessage;
                });
                presenceSubscription.value = subscription;
                _subscriptions.add(subscription);
              }
            : null,
        child: const Text('Subscribe'),
      );

  Widget createChannelPresenceUnsubscribeButton(
    ValueNotifier<StreamSubscription<ably.PresenceMessage?>?>
        presenceSubscription,
  ) =>
      TextButton(
        onPressed: (presenceSubscription.value != null)
            ? () async {
                await presenceSubscription.value!.cancel();
                presenceSubscription.value = null;
              }
            : null,
        child: const Text('Unsubscribe'),
      );

  Widget getRealtimeChannelPresence(
          ValueNotifier<List<ably.PresenceMessage>> presenceMembers) =>
      TextButton(
        onPressed: () async {
          presenceMembers.value =
              await channel.presence.get(const ably.RealtimePresenceParams());
        },
        child: const Text('Get Realtime presence members'),
      );

  final List<dynamic> _presenceData = [
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
        onPressed: () async {
          await channel.presence.enter(_nextPresenceData);
        },
        child: const Text('Enter'),
      );

  Widget updateRealtimePresence() => TextButton(
        onPressed: () async {
          await channel.presence
              .updateClient(Constants.clientId, _nextPresenceData);
        },
        child: const Text('Update'),
      );

  Widget leaveRealtimePresence() => TextButton(
        onPressed: () async {
          await channel.presence.leave(_nextPresenceData);
        },
        child: const Text('Leave'),
      );

  @override
  Widget build(BuildContext context) {
    final latestMessage = useState<ably.PresenceMessage?>(null);
    final presenceSubscription =
        useState<StreamSubscription<ably.PresenceMessage>?>(null);
    final presenceMembers = useState<List<ably.PresenceMessage>>([]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Presence',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: createChannelPresenceSubscribeButton(
                      latestMessage, channel.state, presenceSubscription)),
              Expanded(
                  child: createChannelPresenceUnsubscribeButton(
                      presenceSubscription)),
            ],
          ),
          Text(
            'Presence Message from channel:'
            ' ${latestMessage.value?.data}',
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
          getRealtimeChannelPresence(presenceMembers),
          ...presenceMembers.value
              .map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
              .toList(),
          PaginatedResultViewer<ably.PresenceMessage>(
              title: 'Presence history',
              query: () => channel.presence
                  .history(ably.RealtimeHistoryParams(limit: 10)),
              builder: (context, message, _) => TextRow('clientId',
                  '${message.id}:${message.clientId}:${message.data}')),
        ],
      ),
    );
  }
}
