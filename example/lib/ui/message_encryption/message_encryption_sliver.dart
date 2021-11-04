import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../encrypted_messaging_service.dart';

class MessageEncryptionSliver extends StatelessWidget {
  EncryptedMessagingService? encryptedMessagingService;

  MessageEncryptionSliver(this.encryptedMessagingService, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Message Encryption',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          child: Text(
              'Connect and listen to channel: "${encryptedMessagingService}"'),
          onPressed: encryptedMessagingService?.connect,
        ),
        TextButton(
          child: Text('Publish encrypted message'),
          onPressed: () async {
            await encryptedMessagingService?.publishMessage(
                'Hello', {'payload': 'this should be encrypted'});
          },
        ),
        TextButton(
            child: const Text('Detach from channel'),
            onPressed: encryptedMessagingService?.detach)
      ],
    );
  }
}
