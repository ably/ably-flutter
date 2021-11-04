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
          onPressed: encryptedMessagingService?.connectRealtime,
          child: const Text('Connect and listen to channel: '
              '"${EncryptedMessagingService.channelName}"'),
        ),
        TextButton(
          onPressed: () async {
            await encryptedMessagingService?.publishRealtimeMessage(
                'Hello', {'payload': 'this should be encrypted'});
          },
          child: Text('Publish encrypted message'),
        ),
        TextButton(
            child: const Text('Detach from channel'),
            onPressed: encryptedMessagingService?.detach),
        Text('Rest client'),
        TextButton(child: const Text('Publish rest message'), onPressed: () {
          encryptedMessagingService?.publishRestMessage('Hello', {'payload': 'this should be encrypted'});
        },),
      ],
    );
}
