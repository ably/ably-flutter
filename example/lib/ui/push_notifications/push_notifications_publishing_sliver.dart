import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../constants.dart';
import '../../push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsPublishingSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsPublishingSliver(this._pushNotificationService);

  @override
  Widget build(BuildContext context) => StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Publishing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text('To validate messages were sent, you can subscribe to '
                  'the channel and view the device logs'),
              BoolStreamButton(
                  stream: _pushNotificationService.hasPushChannelStream,
                  onPressed: _pushNotificationService
                      .subscribeToChannelWithPushChannelRule,
                  child: const Text('Subscribe to channel: '
                      '"${Constants.channelNameForPushNotifications}"')),
              BoolStreamButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: _pushNotificationService.publishToChannel,
                child: const Text('Broadcast to channel: '
                    '"${Constants.channelNameForPushNotifications}"'),
              ),
            ],
          ));
}
