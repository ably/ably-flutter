import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/bool_stream_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PushNotificationsPublishingSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsPublishingSliver(this._pushNotificationService);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Publishing to '
              '"${Constants.channelNameForPushNotifications}"',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Each message sent contains a push payload, '
                  'in the ably.Message.extras field.'),
            ),
            Row(
              children: [
                BoolStreamButton(
                  stream: _pushNotificationService.hasPushChannelStream,
                  onPressed: _pushNotificationService
                      .publishNotificationMessageToChannel,
                  child: const Text('Notification Message'),
                ),
                BoolStreamButton(
                  stream: _pushNotificationService.hasPushChannelStream,
                  onPressed:
                      _pushNotificationService.publishDataMessageToChannel,
                  child: const Text('Data Message'),
                ),
              ],
            ),
            BoolStreamButton(
              stream: _pushNotificationService.hasPushChannelStream,
              onPressed: _pushNotificationService
                  .publishDataNotificationMessageToChannel,
              child: const Text('Data + Notification Message'),
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
                onPressed:
                    _pushNotificationService.subscribeToPushLogMetachannel,
                child: const Text('Subscribe to push metachannel: '
                    '${Constants.pushMetaChannelName}')),
          ],
        ),
      );
}
