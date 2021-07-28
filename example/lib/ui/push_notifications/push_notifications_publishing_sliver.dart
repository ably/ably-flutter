import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../constants.dart';
import '../../push_notification_service.dart';
import '../bool_stream_enabled_button.dart';

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
              BoolStreamEnabledButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: _pushNotificationService.publishToChannel,
                child: const Text(
                    'Broadcast to channel: "${Constants.channelNameForPushNotifications}"'),
              ),
            ],
          ));
}
