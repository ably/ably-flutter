import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/bool_stream_button.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PushNotificationsActivationSliver extends HookWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsActivationSliver(this._pushNotificationService,
      {Key? key})
      : super(key: key);

  Future<void> showErrorDialog(
      BuildContext context, ably.AblyException error) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Push notification error'),
        content:
            Text('Failed to perform operation on push notification service. '
                'Please verify your push notification setup with Readme '
                'files in the ably-flutter repository.\n\n'
                '${error.errorInfo?.message}'),
      ),
    );
  }

  Future<void> handleActivateDeviceButton(BuildContext context) async {
    try {
      await _pushNotificationService.activateDevice();
      await showPermissionReminder(context);
    } on ably.AblyException catch (error) {
      await showErrorDialog(context, error);
    }
    await _pushNotificationService.getDevice();
  }

  Future<void> handleDeactivateDeviceButton(BuildContext context) async {
    try {
      await _pushNotificationService.deactivateDevice();
    } on ably.AblyException catch (error) {
      await showErrorDialog(context, error);
    }
    await _pushNotificationService.getDevice();
  }

  Widget buildiOSSimulatorWarningText(bool isIOSSimulator) {
    if (isIOSSimulator) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: 'Warning: ',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          TextSpan(
              text: 'APNs is not available on iOS simulators, so you cannot '
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
  Widget build(BuildContext context) {
    final isIOSSimulator = useState(false);
    useEffect(() {
      if (Platform.isIOS) {
        DeviceInfoPlugin()
            .iosInfo
            .then((info) => isIOSSimulator.value = !info.isPhysicalDevice);
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Activation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          buildiOSSimulatorWarningText(isIOSSimulator.value),
          Row(
            children: [
              Expanded(
                child: BoolStreamButton(
                    stream: _pushNotificationService.hasPushChannelStream,
                    onPressed: () => handleActivateDeviceButton(context),
                    child: const Text('Activate device')),
              ),
              Expanded(
                child: BoolStreamButton(
                    stream: _pushNotificationService.hasPushChannelStream,
                    onPressed: () => handleDeactivateDeviceButton(context),
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

  Future<void> showPermissionReminder(BuildContext context) async {
    if (Platform.isIOS) {
      final authorizationStatus = _pushNotificationService
          .notificationSettingsStream.value.authorizationStatus;
      if (authorizationStatus == ably.UNAuthorizationStatus.notDetermined) {
        await showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Reminder for the developer'),
            content: const Text(
                'You should request permission to show notifications to the '
                'user or a provisional permissions.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  _pushNotificationService.requestNotificationPermission(
                      provisional: true);
                  Navigator.pop(context);
                },
                child: const Text('Request provisional permission'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  _pushNotificationService.requestNotificationPermission();
                  Navigator.pop(context);
                },
                child: const Text('Request permission'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Do not request permission'),
              ),
            ],
          ),
        );
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
}
