import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../service/ably_service.dart';

class RealtimePresenceSliver extends StatefulWidget {
  final AblyService ablyService;

  const RealtimePresenceSliver(this.ablyService, {Key? key}) : super(key: key);

  @override
  _RealtimePresenceSliverState createState() => _RealtimePresenceSliverState();
}

class _RealtimePresenceSliverState extends State<RealtimePresenceSliver> {
  ably.PaginatedResult<ably.PresenceMessage>? _restPresenceMembers;
  ably.PaginatedResult<ably.PresenceMessage>? _restPresenceHistory;
  StreamSubscription<ably.PresenceMessage?>?
  _channelPresenceMessageSubscription;
  ably.PresenceMessage? channelPresenceMessage;
  List<ably.PresenceMessage>? _realtimePresenceMembers;
  ably.PaginatedResult<ably.PresenceMessage>? _realtimePresenceHistory;

  Object? _lastEmittedPresenceData = null;

  // TODO use stream builder and build if stream doesn't have connection, disable the button.
  Widget enterRealtimePresence() => TextButton(
    onPressed: (_realtime == null)
        ? null
        : () async {
      await widget.ablyService.enterRealtimeChannelPresence();
    },
    child: const Text('Enter'),
  );

  Widget updateRealtimePresence() => FlatButton(
    onPressed: (_realtime == null)
        ? null
        : () async {
      await widget.ablyService.updateRealtimeChannelPresence();
    },
    color: Colors.yellow,
    child: const Text('Update'),
  );

  Widget leaveRealtimePresence() => FlatButton(
    onPressed: (_realtime == null) ? null : () async {},
    color: Colors.yellow,
    child: const Text('Leave'),
  );

  Widget createChannelPresenceSubscribeButton() => FlatButton(
    onPressed: (_realtimeChannelState == ably.ChannelState.attached &&
        _channelPresenceMessageSubscription == null)
        ? () {
      ablyService
          .subscribeToRealtimeChannelPresence((presenceMessage) {
        print('Channel presence message received: $presenceMessage');
        setState(() {
          channelPresenceMessage = presenceMessage;
        });
      });
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
      _realtimePresenceMembers =
      await ablyService.getRealtimeChannelPresence();
      setState(() {});
    },
    color: Colors.yellow,
    child: const Text('Get Realtime presence members'),
  );

  Widget getRealtimeChannelPresenceHistory() =>
      getPageNavigator<ably.PresenceMessage>(
          name: 'Realtime presence history',
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

  Widget releaseRealtimeChannelButton() => FlatButton(
    color: Colors.deepOrangeAccent[100],
    onPressed: (_realtime == null)
        ? null
        : () => _realtime!.channels.release(defaultChannel),
    child: const Text('Release Realtime channel'),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Presence',
          style: TextStyle(fontSize: 20),
        ),
        Text('Current Data: $_lastEmittedPresenceData'),
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
        const Text(
          'Realtime Presence',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        releaseRealtimeChannelButton(),
        const Text(
          'Rest Presence',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
      ],
    );
  }
}
