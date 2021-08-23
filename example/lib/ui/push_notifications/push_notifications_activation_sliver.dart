import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsActivationSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;
  final bool isIOSSimulator;

  const PushNotificationsActivationSliver(this._pushNotificationService,
      {required this.isIOSSimulator, Key? key})
      : super(key: key);

  Future<void> handleActivateDeviceButton() async {
    await _pushNotificationService.activateDevice();
    // Just getting the device details immediately.
    await _pushNotificationService.getDevice();
    if (Platform.isIOS) {
      final authorizationStatus = _pushNotificationService
          .notificationSettingsStream.value.authorizationStatus;
      if (authorizationStatus == ably.UNAuthorizationStatus.notDetermined) {
        await Fluttertoast.showToast(
            msg: "You don't have permission from the user yet",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16);
      } else if (authorizationStatus == ably.UNAuthorizationStatus.denied) {
        await Fluttertoast.showToast(
            msg: 'The user has previously denied notifications from this app.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16);
      }
    }
  }

  Future<void> handleDeactivateDeviceButton() async {
    await _pushNotificationService.deactivateDevice();
    // Just getting the device details immediately.
    await _pushNotificationService.getDevice();
  }

  Widget buildiOSSimulatorWarningText() {
    if (isIOSSimulator) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RichText(
            text: const TextSpan(children: [
              TextSpan(
                  text: 'Warning: ',
                  style:
                  TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                  'APNs is not available on iOS simulators, so you cannot '
                      'activate the device Ably, since this step requires the'
                      ' APNs device token.',
                  style: TextStyle(color: Colors.black))
            ])),
      );
    } else {
      return const SizedBox.shrink();
    }
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
            // TODO test emulator on Android can receive messages/ activate with Ably
            buildiOSSimulatorWarningText(),
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
