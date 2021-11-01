import 'dart:io' as io show Platform;

import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../../realtime/realtime.dart';
import '../../rest/rest.dart';
import '../platform.dart';
import 'push_activation_events_native.dart';
import 'push_notification_events_native.dart';

/// The native code implementation of [Push].
class PushNative extends PlatformObject implements Push {
  static PushActivationEvents activationEvents = PushActivationEventsNative();
  static PushNotificationEvents notificationEvents =
      PushNotificationEventsNative();

  /// A rest client used platform side to invoke push notification methods
  final RestInterface? rest;

  /// A realtime client used platform side to invoke push notification methods
  final Realtime? realtime;

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
        TxPushRequestPermission.sound: sound,
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
      throw UnsupportedError('getNotificationSettings is only valid on iOS.');
    }
  }

  @override
  Future<void> deactivate() => invoke(PlatformMethod.pushDeactivate);

  @override
  Future<int?> createPlatformInstance() => (realtime != null)
      ? (realtime as Realtime).handle
      : (rest as Rest).handle;
}
