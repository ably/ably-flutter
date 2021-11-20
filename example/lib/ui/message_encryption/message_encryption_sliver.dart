import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/encrypted_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MessageEncryptionSliver extends StatelessWidget {
  final EncryptedMessagingService? encryptedMessagingService;

  const MessageEncryptionSliver(this.encryptedMessagingService, {Key? key})
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
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
                'Channel name: "${EncryptedMessagingService.channelName}"'),
          ),
          const Text(
            'Realtime Client',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            'Rest Client',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            child: const Text('Publish rest message'),
            onPressed: () {
              encryptedMessagingService?.publishRestMessage(
                  'Hello', {'payload': 'this should be encrypted'});
            },
          ),
          const Text(
            'Message history:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<List<ably.Message>>(
            stream: encryptedMessagingService?.messageHistoryStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final messages = snapshot.data as List<ably.Message>;
                if (messages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No messages yet'),
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
                return const Text('No messages yet');
              }
            },
          ),
        ],
      );
}
