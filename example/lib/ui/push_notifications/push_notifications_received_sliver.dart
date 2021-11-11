import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/widgets.dart';

import '../../push_notifications/push_notification_handlers.dart';
import '../text_with_label.dart';

class PushNotificationsReceivedSliver extends StatelessWidget {
  const PushNotificationsReceivedSliver();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Received messages',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<List<ably.RemoteMessage>>(
              stream: PushNotificationHandlers.receivedMessagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Widget not loaded yet.');
                }
                final messages = snapshot.data;
                if (messages!.isEmpty) {
                  return const Text('No messages yet');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: messages
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWithLabel('Title',
                                      e.notification?.title ?? 'NO TITLE'),
                                  TextWithLabel('Body',
                                      e.notification?.body ?? 'NO BODY'),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                }
              }),
        ],
      );
}
