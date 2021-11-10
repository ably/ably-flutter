import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/bool_stream_button.dart';
import 'package:ably_flutter_example/ui/text_with_label.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
            buildRequestProvisionalPermissionButton(),
            buildRequestNotificationPermissionButton(),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  BoolStreamButton buildRequestProvisionalPermissionButton() =>
      BoolStreamButton(
        stream: _pushNotificationService.hasPushChannelStream,
        onPressed: () {
          _pushNotificationService.requestNotificationPermission(
              provisional: true);
          Fluttertoast.showToast(
              msg: 'Notifications will be delivered silently to '
                  'the notification center.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16);
        },
        child: const Text('Request Provisional Permission (no alert)'),
      );

  BoolStreamButton buildRequestNotificationPermissionButton() =>
      BoolStreamButton(
        stream: _pushNotificationService.hasPushChannelStream,
        onPressed: _pushNotificationService.requestNotificationPermission,
        child: const Text('Request Permission'),
      );

  Widget buildIOSNotificationSettings() {
    if (Platform.isIOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: StreamBuilder<ably.UNNotificationSettings?>(
          stream: _pushNotificationService.notificationSettingsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No iOS permission information to show yet.');
            } else {
              final settings =
                  snapshot.data as ably.UNNotificationSettings;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'iOS Notification Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextRow('Authorization Status',
                      '${settings.authorizationStatus}'),
                  TextRow('Sound', '${settings.soundSetting}'),
                  TextRow('Badge', '${settings.badgeSetting}'),
                  TextRow('Alert', '${settings.alertSetting}'),
                  TextRow('Notification Center',
                      '${settings.notificationCenterSetting}'),
                  TextRow('Lock Screen',
                      '${settings.lockScreenSetting}'),
                  TextRow('Alert Style', '${settings.alertStyle}'),
                  TextRow('Shows Preview',
                      '${settings.showPreviewsSetting}'),
                  TextRow('Critical Alerts',
                      '${settings.criticalAlertSetting}'),
                  TextRow('providesAppNotificationSettings',
                      '${settings.providesAppNotificationSettings}'),
                  TextRow('Siri announcements',
                      '${settings.announcementSetting}'),
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
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          buildIOSPermissionSliver(),
          buildIOSNotificationSettings(),
        ],
      );
}
