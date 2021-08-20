import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsActivationSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsActivationSliver(this._pushNotificationService,
      {Key? key})
      : super(key: key);

  Future<void> handleActivateDeviceButton() async {
    await _pushNotificationService.activateDevice();
    // Just getting the device details immediately.
    await _pushNotificationService.getDevice();
  }

  Future<void> handleDeactivateDeviceButton() async {
    await _pushNotificationService.deactivateDevice();
    // Just getting the device details immediately.
    await _pushNotificationService.getDevice();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Activation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: BoolStreamButton(
                      stream: _pushNotificationService.hasPushChannelStream,
                      onPressed: handleActivateDeviceButton,
                      child: const Text('Activate device')),
                ),
                Expanded(
                  child: BoolStreamButton(
                      stream: _pushNotificationService.hasPushChannelStream,
                      onPressed: handleDeactivateDeviceButton,
                      child: const Text('Deactivate device')),
                ),
              ],
            ),
            const Text('Once devices are activated, a Push Admin can '
                "send push messages to devices by it's device ID, client ID or "
                'FCM/ APNs token. To send push messages between users, the '
                'device must push-subscribe to the channel and a push payload '
                'is added to the channel message.'),
          ],
        ),
      );
}
