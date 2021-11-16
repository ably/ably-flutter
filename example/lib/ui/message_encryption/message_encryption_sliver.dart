import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../encrypted_messaging_service.dart';

class MessageEncryptionSliver extends StatelessWidget {
  EncryptedMessagingService? encryptedMessagingService;

  MessageEncryptionSliver(this.encryptedMessagingService, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Message Encryption',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
                'Channel name: "${EncryptedMessagingService.channelName}"'),
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
                      'Hello', {'payload': 'this should be encrypted'});
                },
              ),
              TextButton(
                onPressed: () async {
                  await encryptedMessagingService?.publishRealtimeMessage(
                      'Hello', {'payload': 'this should be encrypted'});
                },
                child: const Text('Realtime client'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent messages:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: encryptedMessagingService?.clearMessageHistory,
                  icon: const Icon(Icons.delete))
            ],
          ),
          TextButton(
            onPressed: encryptedMessagingService?.logChannelMessages,
            child: const Text('Log channel messages'),
          ),
          TextButton(
              onPressed: encryptedMessagingService?.unsubscribeAndDetach,
              child: const Text('Unsubscribe and detach from channel')),
          StreamBuilder<List<ably.Message>>(
            stream: encryptedMessagingService?.messageHistoryStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final messages = snapshot.data as List<ably.Message>;
                if (messages.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: const Text('No messages yet'),
                  );
                }

                return Column(
                  children: messages
                      .map((message) => Row(
                            children: [
                              Text((message.name != null)
                                  ? message.name.toString()
                                  : 'NO NAME'),
                              Text((message.data != null)
                                  ? message.data.toString()
                                  : 'NO DATA'),
                            ],
                          ))
                      .toList(),
                );
              } else {
                return Text('No messages yet');
              }
            },
          ),
        ],
      );
}
