import 'dart:io' as io show Platform;

import 'package:ably_flutter/src/push_notifications/src/ios_notification_settings.dart';

import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../../realtime/realtime.dart';
import '../../rest/rest.dart';
import '../platform.dart';

/// The native code implementation of [Push].
class PushNative extends PlatformObject implements Push {
  /// A rest client used platform side to invoke push notification methods
  final RestInterface? rest;

  /// A realtime client used platform side to invoke push notification methods
  final RealtimeInterface? realtime;

  /// Pass an Ably realtime or rest client.
  PushNative({this.rest, this.realtime}) : super() {
    final ablyClientNotPresent = rest == null && realtime == null;
    final moreThanOneAblyClientPresent = rest != null && realtime != null;
    if (ablyClientNotPresent || moreThanOneAblyClientPresent) {
      throw Exception(
          'Specify one Ably client when creating ${(PushNative).toString()}.');
    }
  }

  @override
  Future<void> activate() => invoke(PlatformMethod.pushActivate);

  @override
  Future<bool> requestPermission(
      {bool badge = true,
      bool sound = true,
      bool alert = true,
      bool carPlay = true,
      bool criticalAlert = false,
      bool provisional = false,
      bool providesAppNotificationSettings = false,
      bool announcement = true}) async {
    if (io.Platform.isIOS) {
      return invokeRequest<bool>(PlatformMethod.pushRequestPermission, {
        TxPushRequestPermission.badge: badge,
        TxPushRequestPermission.alert: alert,
        TxPushRequestPermission.carPlay: carPlay,
        TxPushRequestPermission.criticalAlert: criticalAlert,
        TxPushRequestPermission.provisional: provisional,
        TxPushRequestPermission.providesAppNotificationSettings:
            providesAppNotificationSettings,
        TxPushRequestPermission.announcement: announcement,
      });
    } else {
      return true;
    }
  }

  @override
  Future<UNNotificationSettings> getNotificationSettings() async {
    if (io.Platform.isIOS) {
      return invokeRequest<UNNotificationSettings>(
          PlatformMethod.pushGetNotificationSettings);
    } else {
      throw UnsupportedError('This is an iOS-only method.');
    }
  }

  @override
  Future<void> deactivate() => invoke(PlatformMethod.pushDeactivate);

  @override
  Future<void> openSettings() {
    if (io.Platform.isIOS) {
      return invokeRequest<UNNotificationSettings>(
          PlatformMethod.pushOpenSettingsForNotification);
    } else {
      throw UnsupportedError('This is an iOS-only method.');
    }
  }

  @override
  Future<int?> createPlatformInstance() => (realtime != null)
      ? (realtime as Realtime).handle
      : (rest as Rest).handle;
}
