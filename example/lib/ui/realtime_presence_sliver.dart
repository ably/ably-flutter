import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RealtimePresenceSliver extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Presence',
          style: TextStyle(fontSize: 20),
        ),
        Text('Current Data: $_currentPresenceData'),
        Row(
          children: <Widget>[
            Expanded(child: createChannelPresenceSubscribeButton()),
            Expanded(child: createChannelPresenceUnSubscribeButton()),
          ],
        ),
        Text(
          'Presence Message from channel:'
              ' ${channelPresenceMessage?.data ?? '-'}',
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
        getRealtimeChannelPresenceHistory(),
        ..._realtimePresenceHistory?.items
            .map((m) => Text('${m.id}:${m.clientId}:${m.data}'))
            .toList() ??
            [],
      ],
    )
  }

}