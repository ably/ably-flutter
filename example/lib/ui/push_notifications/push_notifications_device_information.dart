import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../push_notifications/push_notification_service.dart';

class PushNotificationsDeviceInformation extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsDeviceInformation(this._pushNotificationService,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Local Device information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<ably.LocalDevice?>(
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
        ),
      ],
    ),
  );

}