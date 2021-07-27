import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../constants.dart';
import '../../op_state.dart';

class PushNotificationsPublishingSliver extends StatelessWidget {
  final ably.PushChannel? _pushChannel;
  final OpState _deviceActivationState;
  final ably.RealtimeChannelInterface? _realtimeChannel;
  final ably.RestChannelInterface? _restChannel;

  PushNotificationsPublishingSliver(this._pushChannel,
      this._deviceActivationState, this._realtimeChannel, this._restChannel);

  bool get enablePublishButtons =>
      _deviceActivationState == OpState.succeeded && _pushChannel != null;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Publishing',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: enablePublishButtons ? publishToChannel : null,
            child: const Text(
                'Broadcast to channel: "${Constants.channelNameForPushNotifications}"'),
          ),
        ],
      );

  final ably.Message _pushMessage = ably.Message(
      extras: const ably.MessageExtras({
    'push': {
      'notification': {
        'title': 'Hello from Ably!',
        'body': 'Example push notification from Ably.'
      },
      'data': {'foo': 'bar', 'baz': 'quz'}
    },
  }));

  void publishToChannel() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.publish(message: _pushMessage);
    } else if (_restChannel != null) {
      _restChannel!.publish(message: _pushMessage);
    }
  }
}
