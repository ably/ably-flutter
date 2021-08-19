import 'dart:io';

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

  Widget buildNotificationSettingsSliver() =>
      StreamBuilder<ably.UNNotificationSettings?>(
        stream: _pushNotificationService.notificationSettingsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Text('No iOS permission information to show yet.');
          } else {
            final unNotificationSettings =
                snapshot.data as ably.UNNotificationSettings;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'iOS Notification Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Authorization Status: '
                    '${unNotificationSettings.authorizationStatus}'),
                Text('Sound: ${unNotificationSettings.soundSetting}'),
                Text('Badge: ${unNotificationSettings.badgeSetting}'),
                Text('Alert: ${unNotificationSettings.alertSetting}'),
                Text('Notification Center: '
                    '${unNotificationSettings.notificationCenterSetting}'),
                Text(
                    'Lock Screen: ${unNotificationSettings.lockScreenSetting}'),
                Text('Alert Style: ${unNotificationSettings.alertStyle}'),
                Text('Shows Preview: '
                    '${unNotificationSettings.showPreviewsSetting}'),
                Text('Critical Alerts: '
                    '${unNotificationSettings.criticalAlertSetting}'),
                Text('providesAppNotificationSettings: '
                    '${unNotificationSettings.providesAppNotificationSettings}'),
                Text('Siri announcements: '
                    '${unNotificationSettings.announcementSetting}'),
              ],
            );
          }
        },
      );

  Widget buildUserPermissionSliver() {
    if (Platform.isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'iOS Permissions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          BoolStreamButton(
            stream: _pushNotificationService.hasPushChannelStream,
            onPressed: () {
              _pushNotificationService.requestNotificationPermission(
                  provisional: true);
            },
            child: const Text('Request Provisional User Permission (no alert)'),
          ),
          BoolStreamButton(
            stream: _pushNotificationService.hasPushChannelStream,
            onPressed: () {
              _pushNotificationService.requestNotificationPermission(
                  provisional: false);
            },
            child: const Text('Request User Permission'),
          ),
          buildNotificationSettingsSliver(),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
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
          buildUserPermissionSliver(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: const Text('Once devices are activated, a Push Admin can '
                'send push messages to devices by it\'s device ID or'
                ' client ID.'),
          ),
          const Text(
            'Local Device information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          buildLocalDeviceInformation(),
        ],
      );
}
