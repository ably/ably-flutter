import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsSubscriptionsSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsSubscriptionsSliver(this._pushNotificationService,
      {Key? key})
      : super(key: key);

  Widget buildSubscriptionsList() => StreamBuilder<
          ably.PaginatedResultInterface<ably.PushChannelSubscription>>(
      stream: _pushNotificationService.pushChannelSubscriptionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final subscriptions = snapshot.data
              as ably.PaginatedResultInterface<ably.PushChannelSubscription>;
          return Column(children: [
            ...subscriptions.items
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            (subscriptions.hasNext()
                ? const Text('and more...')
                : const SizedBox.shrink())
          ]);
        }
        return const SizedBox.shrink();
      });

  Widget buildNotificationPermissionGrantedStatus() => StreamBuilder(
        stream:
            _pushNotificationService.userNotificationPermissionGrantedStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('User Notification Permission: '
                'Permission not yet requested');
          } else {
            final permissionGranted = snapshot.data as bool;
            if (permissionGranted) {
              return const Text('User Notification Permission: '
                  'Permission granted');
            } else {
              return const Text('User Notification Permission: '
                  'Permission not granted.');
            }
          }
        },
      );

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
            const Text('If you subscribe both device and client, '
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
                      .listSubscriptionsWithDeviceId();
                  print('Push subscriptions: ${subscriptions.items}');
                },
                child: const Text('List subscriptions with current device ID')),
            BoolStreamButton(
                stream: _pushNotificationService.hasPushChannelStream,
                onPressed: () async {
                  final subscriptions = await _pushNotificationService
                      .listSubscriptionsWithClientId();
                  print('Push subscriptions: ${subscriptions.items}');
                },
                child: const Text('List subscriptions with current client ID')),
            buildSubscriptionsList(),
            BoolStreamButton(
              stream: _pushNotificationService.hasPushChannelStream,
              onPressed: _pushNotificationService.requestNotificationPermission,
              child: const Text('Request User Permission (iOS only)'),
            ),
            buildNotificationPermissionGrantedStatus(),
          ],
        ),
      );
}
