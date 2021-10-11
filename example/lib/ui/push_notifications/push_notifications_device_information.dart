import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../push_notifications/push_notification_service.dart';
import '../text_with_label.dart';

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
                      TextWithLabel('deviceId', localDevice.id),
                      TextWithLabel('clientId', localDevice.clientId),
                      TextWithLabel(
                          'platform', localDevice.platform.toString()),
                      TextWithLabel(
                          'formFactor', localDevice.formFactor.toString()),
                      TextWithLabel(
                          'metadata', localDevice.metadata.toString()),
                      TextWithLabel('DevicePushDetails state',
                          localDevice.push.state.toString()),
                      TextWithLabel('DevicePushDetails recipient',
                          '${localDevice.push.recipient}'),
                      TextButton(
                        onPressed: _pushNotificationService.getDevice,
                        child: const Text('Refresh local device information'),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _pushNotificationService.getPushState,
                            child: const Text('Get push state'),
                          ),
                          StreamBuilder(
                            stream: _pushNotificationService.pushStateStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const Text('No push state yet.');
                              } else {
                                final devicePushDetails =
                                    snapshot.data as ably.DevicePushDetails;
                                return Text(devicePushDetails.state.toString());
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  );
                }
                return RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                      text: 'Warning: ',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
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
