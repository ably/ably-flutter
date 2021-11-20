import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushRealtimeClientReceivedSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushRealtimeClientReceivedSliver(this._pushNotificationService);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const Text(
              'Debugging messages (via realtime client)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text('To validate messages were sent, you can subscribe to '
                'the channel and view the device logs.'),
            BoolStreamButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: _pushNotificationService
                    .subscribeToChannelWithPushChannelRule,
                child: const Text('Subscribe to channel: '
                    '"${Constants.channelNameForPushNotifications}"')),
            const Text('To debug push notifications, '
                'subscribe to the meta channel.'),
            BoolStreamButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed:
                    _pushNotificationService.subscribeToPushLogMetachannel,
                child: const Text('Subscribe to push metachannel: '
                    '${Constants.pushMetaChannelName}')),
          ],
        ),
      );
}
