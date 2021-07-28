import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../constants.dart';
import '../../op_state.dart';
import '../../push_notification_service.dart';
import '../bool_stream_enabled_button.dart';

class PushNotificationsSubscriptionsSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsSubscriptionsSliver(this._pushNotificationService,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Subscriptions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            BoolStreamEnabledButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: () async {
                  final subscriptions =
                      await _pushNotificationService.listSubscriptions();
                  print('Subscriptions: ${subscriptions.items}');
                },
                child: const Text('List subscriptions')),
            Row(
              children: [
                Expanded(
                  child: BoolStreamEnabledButton(
                      streams: [
                        _pushNotificationService.hasPushChannelStream,
                        _pushNotificationService.deviceActivationStateStream
                            .map((state) => state == OpState.succeeded)
                      ],
                      onPressed: _pushNotificationService.subscribeDevice,
                      child: const Text('Subscribe device')),
                ),
                Expanded(
                  child: BoolStreamEnabledButton(
                    streams: [
                      _pushNotificationService.hasPushChannelStream,
                      _pushNotificationService.deviceActivationStateStream
                          .map((state) => state == OpState.succeeded)
                    ],
                    onPressed: _pushNotificationService.unsubscribeDevice,
                    child: const Text('Unsubscribe device'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: BoolStreamEnabledButton(
                      streams: [
                        _pushNotificationService.hasPushChannelStream,
                        _pushNotificationService.deviceActivationStateStream
                            .map((state) => state == OpState.succeeded)
                      ],
                      onPressed: _pushNotificationService.subscribeClient,
                      child: const Text('Subscribe client')),
                ),
                Expanded(
                  child: BoolStreamEnabledButton(
                      streams: [
                        _pushNotificationService.hasPushChannelStream,
                        _pushNotificationService.deviceActivationStateStream
                            .map((state) => state == OpState.succeeded)
                      ],
                      onPressed: _pushNotificationService.unsubscribeClient,
                      child: const Text('Unsubscribe client')),
                )
              ],
            ),
            const Text('To validate messages were sent, you can subscribe to '
                'the channel and view the logs'),
            BoolStreamEnabledButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: _pushNotificationService
                    .subscribeToChannelWithPushChannelRule,
                child: const Text('Subscribe to channel: '
                    '"${Constants.channelNameForPushNotifications}"'))
          ],
        ),
      );
}
