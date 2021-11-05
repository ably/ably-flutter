import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ably_flutter/ably_flutter.dart' as ably;

import '../../encrypted_messaging_service.dart';

class MessageEncryptionSliver extends StatelessWidget {
  EncryptedMessagingService? encryptedMessagingService;

  MessageEncryptionSliver(this.encryptedMessagingService, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Message Encryption',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Text('The "${EncryptedMessagingService.channelName}" channel'
              ' will be used.'),
          const Text(
            'Realtime client',
            style: TextStyle(fontSize: 16),
          ),
          TextButton(
            onPressed: encryptedMessagingService?.logChannelMessages,
            child: const Text('Log channel messages'),
          ),
          TextButton(
            onPressed: () async {
              await encryptedMessagingService?.publishRealtimeMessage(
                  'Hello', {'payload': 'this should be encrypted'});
            },
            child: const Text('Publish encrypted message'),
          ),
          TextButton(
              onPressed: encryptedMessagingService?.unsubscribeAndDetach,
              child: const Text('Unsubscribe and detach from channel')),
          const Text(
            'Rest client',
            style: TextStyle(fontSize: 16),
          ),
          TextButton(
            child: const Text('Publish rest message'),
            onPressed: () {
              encryptedMessagingService?.publishRestMessage(
                  'Hello', {'payload': 'this should be encrypted'});
            },
          ),
          const Text('Message history:'),
          StreamBuilder<List<ably.Message>>(
            stream: encryptedMessagingService?.messageHistoryStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final messages = snapshot.data as List<ably.Message>;
                return Column(
                  children: messages
                      .map((message) => Row(
                            children: [
                              Text((message.name != null)
                                  ? message.name.toString()
                                  : "NO NAME"),
                              Text((message.data != null)
                                  ? message.data.toString()
                                  : "NO DATA"),
                            ],
                          ))
                      .toList(),
                );
              } else {
                return Text("No messages yet");
              }
            },
          ),
        ],
      );
}
