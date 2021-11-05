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
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Message Encryption',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Text('Realtime client'),
          TextButton(
            onPressed: encryptedMessagingService?.subscribeToChannel,
            child: const Text('Subscribe to channel: '
                '"${EncryptedMessagingService.channelName}"'),
          ),
          TextButton(
            onPressed: () async {
              await encryptedMessagingService?.publishRealtimeMessage(
                  'Hello', {'payload': 'this should be encrypted'});
            },
            child: const Text('Publish encrypted message'),
          ),
          TextButton(
              onPressed: encryptedMessagingService?.detach,
              child: const Text('Detach from channel')),
          const Text('Rest client'),
          TextButton(
            child: const Text('Publish rest message'),
            onPressed: () {
              encryptedMessagingService?.publishRestMessage(
                  'Hello', {'payload': 'this should be encrypted'});
            },
          ),
        ],
      );
}
