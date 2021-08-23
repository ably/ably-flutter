import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsSubscriptionsSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsSubscriptionsSliver(this._pushNotificationService,
      {Key? key})
      : super(key: key);

  Widget buildSubscriptionsList(
          Stream<ably.PaginatedResultInterface<ably.PushChannelSubscription>>
              stream) =>
      StreamBuilder<
              ably.PaginatedResultInterface<ably.PushChannelSubscription>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final subscriptions = snapshot.data as ably
                  .PaginatedResultInterface<ably.PushChannelSubscription>;

              if (subscriptions.items.isEmpty) {
                return const Text('No subscriptions');
              }

              final theresMoreSubscriptionsWidget = subscriptions.hasNext()
                  ? const Text('and more...')
                  : const SizedBox.shrink();

              return Column(children: [
                ...subscriptions.items
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          color: Colors.grey[200],
                          child: Column(children: [
                            Text('Channel: ${e.channel}'),
                            if (e.deviceId != null)
                              Text('DeviceId: ${e.deviceId!}')
                            else
                              Text('ClientId: ${e.clientId}'),
                          ]),
                        ),
                      ),
                    )
                    .toList(),
                theresMoreSubscriptionsWidget
              ]);
            }
            return const Text('List subscription button not pressed.');
          });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Push channel subscriptions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
                'You need to use a token/ key with the Push Admin capability '
                    'to list subscriptions by client ID or device ID. '
                    'If you subscribe both device and client to the channel, '
                'the device will receive 2 notifications.'),
            Row(
              children: [
                Expanded(
                  child: BoolStreamButton(
                      stream: _pushNotificationService.hasPushChannelStream,
                      onPressed: _pushNotificationService.subscribeDevice,
                      child: const Text('Subscribe device')),
                ),
                Expanded(
                  child: BoolStreamButton(
                    stream: _pushNotificationService.hasPushChannelStream,
                    onPressed: _pushNotificationService.unsubscribeDevice,
                    child: const Text('Unsubscribe device'),
                  ),
                ),
              ],
            ),
            BoolStreamButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: () async {
                  final subscriptions = await _pushNotificationService
                      .listSubscriptionsWithDeviceId();
                  print('Push subscriptions: ${subscriptions.items}');
                },
                child: const Text('List subscriptions with current device ID')),
            buildSubscriptionsList(
                _pushNotificationService.pushChannelDeviceSubscriptionsStream),
            Row(
              children: [
                Expanded(
                  child: BoolStreamButton(
                      stream: _pushNotificationService.hasPushChannelStream,
                      onPressed: _pushNotificationService.subscribeClient,
                      child: const Text('Subscribe client')),
                ),
                Expanded(
                  child: BoolStreamButton(
                      stream: _pushNotificationService.hasPushChannelStream,
                      onPressed: _pushNotificationService.unsubscribeClient,
                      child: const Text('Unsubscribe client')),
                )
              ],
            ),
            BoolStreamButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: () async {
                  final subscriptions = await _pushNotificationService
                      .listSubscriptionsWithClientId();
                  print('Push subscriptions: ${subscriptions.items}');
                },
                child: const Text('List subscriptions with current client ID')),
            buildSubscriptionsList(
                _pushNotificationService.pushChannelClientSubscriptionsStream),
            buildWarningTextForListSubscriptionsOnAndroid(),
          ],
        ),
      );

  Widget buildWarningTextForListSubscriptionsOnAndroid() {
    if (Platform.isAndroid) {
      return Padding(
        child: RichText(
          text:
              const TextSpan(style: TextStyle(color: Colors.black), children: [
            TextSpan(
                text: 'Warning: ',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            TextSpan(
                text: 'A bug in ably-java means all client ID and device '
                    'ID subscriptions are returned when you call '
                    'push.listSubscriptions. Track ably-java issue #705'),
          ]),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
      );
    }
    return const SizedBox.shrink();
  }
}
