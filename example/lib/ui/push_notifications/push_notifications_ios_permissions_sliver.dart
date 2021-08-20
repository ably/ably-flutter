import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../push_notifications/push_notification_service.dart';
import '../bool_stream_button.dart';

class PushNotificationsIOSNotificationSettingsSliver extends StatelessWidget {
  final PushNotificationService _pushNotificationService;

  const PushNotificationsIOSNotificationSettingsSliver(
      this._pushNotificationService,
      {Key? key})
      : super(key: key);

  Widget buildIOSPermissionSliver() {
    if (Platform.isIOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
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
              child: const Text('Request Provisional Permission (no alert)'),
            ),
            BoolStreamButton(
              stream: _pushNotificationService.hasPushChannelStream,
              onPressed: () {
                _pushNotificationService.requestNotificationPermission();
                Fluttertoast.showToast(
                    msg:
                    "Notifications will be delivered silently to the notification center.",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16);
              },
              child: const Text('Request Permission'),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildIOSNotificationSettings() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: StreamBuilder<ably.UNNotificationSettings?>(
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
              TextButton(
                onPressed:
                _pushNotificationService.updateNotificationSettings,
                child: const Text('Refresh notification settings'),
              ),
            ],
          );
        }
      },
    ),
  );


  @override
  Widget build(BuildContext context) => Column(
    children: [
      buildIOSPermissionSliver(),
      buildIOSNotificationSettings(),
    ],
  );
}
