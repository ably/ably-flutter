import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsActivationSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsActivationSliver(this._pushNotificationService,
      {Key? key})
      : super(key: key);

  Widget buildLocalDeviceInformation() => StreamBuilder<ably.LocalDevice?>(
        stream: _pushNotificationService.localDeviceStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final localDevice = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('deviceId: ${localDevice.id}'),
                Text('clientId: ${localDevice.clientId}'),
                Text('platform: ${localDevice.platform}'),
                Text('formFactor: ${localDevice.formFactor}'),
                Text('metadata: ${localDevice.metadata}'),
                Text('DevicePushDetails state: ${localDevice.push.state}'),
                Text('DevicePushDetails recipient: '
                    '${localDevice.push.recipient}'),
                TextButton(
                  onPressed: _pushNotificationService.getDevice,
                  child: const Text('Refresh local device information'),
                ),
              ],
            );
          }
          return RichText(
              text: const TextSpan(children: [
            TextSpan(
                text: 'Warning: ',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            TextSpan(
                text: 'no local device information yet.',
                style: TextStyle(color: Colors.black))
          ]));
        },
      );

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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Activation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
          const Text(
            'Local Device information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          buildLocalDeviceInformation(),
        ],
      );
}
