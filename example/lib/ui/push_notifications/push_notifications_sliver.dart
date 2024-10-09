import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_activation_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_device_information.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_ios_permissions_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_publishing_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_received_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_subscriptions_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_realtime_client_received_sliver.dart';
import 'package:flutter/material.dart';

class PushNotificationsSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsSliver(this._pushNotificationService, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Push Notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          buildSummaryText(),
          PushNotificationsActivationSliver(
            pushNotificationService: _pushNotificationService,
          ),
          PushNotificationsDeviceInformation(
            pushNotificationService: _pushNotificationService,
          ),
          PushNotificationsIOSNotificationSettingsSliver(
            pushNotificationService: _pushNotificationService,
          ),
          PushNotificationsSubscriptionsSliver(
            pushNotificationService: _pushNotificationService,
          ),
          PushNotificationsPublishingSliver(
              pushNotificationService: _pushNotificationService),
          const PushNotificationsReceivedSliver(),
          PushRealtimeClientReceivedSliver(
            pushNotificationService: _pushNotificationService,
          ),
        ],
      );

  Widget buildSummaryText() => const Column(
        children: [
          Text(
              'Activate your device, view your local device information, '
              'subscribe to a push channel with either your device or '
              'client ID, and then publish to the channel.',
              style: TextStyle(color: Colors.black)),
          SizedBox(height: 16),
        ],
      );
}
