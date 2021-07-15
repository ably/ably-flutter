import 'package:flutter/widgets.dart';

class RestPresenceSliver extends StatefulWidget {
  const RestPresenceSliver({Key? key}) : super(key: key);

  @override
  _RestPresenceSliverState createState() => _RestPresenceSliverState();
}

class _RestPresenceSliverState extends State<RestPresenceSliver> {
  Widget getRestChannelPresence() => getPageNavigator<ably.PresenceMessage>(
      name: 'Rest presence members',
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

  @override
  Widget build(BuildContext context) {
    return Text("Not yet implemented");
  }
}
