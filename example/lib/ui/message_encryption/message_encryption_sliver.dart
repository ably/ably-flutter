import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../encrypted_messaging_service.dart';
import '../text_row.dart';

class MessageEncryptionSliver extends HookWidget {
  final EncryptedMessagingService? encryptedMessagingService;

  const MessageEncryptionSliver(this.encryptedMessagingService, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logMessages = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Message Encryption',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Channel name: "${Constants.encryptedChannelName}"'),
        ),
        const Text(
          'Publish encrypted message using:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: const Text('Rest client'),
              onPressed: () {
                encryptedMessagingService?.publishRestMessage(
                    'Encrypted message',
                    {'payload': 'this should be encrypted'});
              },
            ),
            TextButton(
              onPressed: () async {
                await encryptedMessagingService?.publishRealtimeMessage(
                    'Encrypted message',
                    {'payload': 'this should be encrypted'});
              },
              child: const Text('Realtime client'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subscribe to channel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Switch(
              onChanged: (switchedOn) {
                logMessages.value = switchedOn;
                if (switchedOn) {
                  encryptedMessagingService?.logChannelMessages();
                } else {
                  encryptedMessagingService?.unsubscribeAndDetach();
                }
              },
              value: logMessages.value,
            ),
            IconButton(
                onPressed: encryptedMessagingService?.clearMessageHistory,
                icon: const Icon(Icons.delete))
          ],
        ),
        StreamBuilder<List<ably.Message>>(
          stream: encryptedMessagingService?.messageHistoryStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final messages = snapshot.data as List<ably.Message>;
              if (messages.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: messages
                      .map((message) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextRow(
                                    'Name',
                                    (message.name != null)
                                        ? message.name.toString()
                                        : 'NO NAME'),
                                TextRow(
                                    'Data',
                                    (message.data != null)
                                        ? message.data.toString()
                                        : 'NO DATA'),
                              ],
                            ),
                          ))
                      .toList(),
                );
              } else if (!logMessages.value) {
                return const Text(
                    'Toggle the subscription to show messages here');
              } else {
                return const Text('No messages yet');
              }
            }
            return const Text('No data yet');
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextRow(
            'Hint',
            'You can confirm messages are encrypted by visiting your '
                'application dashboard on ably.com > "Dev console" tab > '
                '"Channels", and attach to the '
                '"${Constants.encryptedChannelName}" channel.',
          ),
        ),
      ],
    );
  }
}
