import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushRealtimeClientReceivedSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushRealtimeClientReceivedSliver(this._pushNotificationService);


  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Text(
            'Debugging messages (via realtime client)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Text('To validate messages were sent, you can subscribe to '
              'the channel and view the device logs. Data messages '
              'are not currently available through Ably-flutter. '
              'You should implement the relevant delegate methods on iOS'
              ' and extend FirebaseMessagingService on Android.'),
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
              onPressed: _pushNotificationService.subscribeToPushLogMetachannel,
              child: const Text('Subscribe to push metachannel: '
                  '${Constants.pushMetaChannelName}')),
        ],
      );
}
