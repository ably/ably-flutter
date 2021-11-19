import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/ui/paginated_result_viewer.dart';
import 'package:ably_flutter_example/ui/text_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RestSliver extends HookWidget {
  final ably.Rest rest;
  late final ably.RestChannel channel;

  RestSliver(this.rest, {Key? key}) : super(key: key) {
    channel = rest.channels.get(Constants.channelName);
  }

  Widget buildPublishButton(ValueNotifier<int> messageCount) {
    final messageName = 'Message $messageCount';
    return TextButton(
      onPressed: () async {
        try {
          await channel.publish(
              name: messageName, data: 'Some data for Message $messageCount');
          messageCount.value += 1;
        } on ably.AblyException catch (e) {
          print('Rest message sending failed:: $e :: ${e.errorInfo}');
        }
      },
      child: Text('Publish message: "$messageName"'),
    );
  }

  Widget buildReleaseRestChannelButton() => TextButton(
        onPressed: () => rest.channels.release(Constants.channelName),
        child: const Text('Release Rest channel'),
      );

  @override
  Widget build(BuildContext context) {
    final messageCount = useState(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rest',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        buildPublishButton(messageCount),
        buildReleaseRestChannelButton(),
        PaginatedResultViewer<ably.Message>(
            title: 'History',
            query: () => channel.history(ably.RestHistoryParams(
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
            query: () =>
                channel.presence.get(ably.RestPresenceParams(limit: 10)),
            builder: (context, message, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextRow('Message ID', '${message.id}'),
                    TextRow('Message client ID', '${message.clientId}'),
                    TextRow('Message data', '${message.data}'),
                  ],
                )),
        PaginatedResultViewer<ably.PresenceMessage>(
            title: 'Presence history',
            query: () =>
                channel.presence.history(ably.RestHistoryParams(limit: 10)),
            builder: (context, message, _) => TextRow('Message name',
                '${message.id}:${message.clientId}:${message.data}')),
      ],
    );
  }
}
