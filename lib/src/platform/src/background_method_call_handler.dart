import 'package:flutter/services.dart';
import 'package:flutter/src/services/platform_channel.dart';

import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../platform_internal.dart';
import 'push_notification_events_native.dart';

class BackgroundMethodCallHandler {
  BackgroundMethodCallHandler(MethodChannel backgroundMethodChannel) {
    backgroundMethodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.pushOnBackgroundMessage:
          return onPushBackgroundMessage(call.arguments as RemoteMessage);
        default:
          throw PlatformException(
              code: 'invalid_method', message: 'No such method ${call.method}');
      }
    });
  }

  PushNotificationEventsNative _pushNotificationEvents =
      PushNative.notificationEvents as PushNotificationEventsNative;

  Future<Object?> onPushBackgroundMessage(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.handleBackgroundMessage(remoteMessage);
  }
}
