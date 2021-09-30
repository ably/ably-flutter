import 'dart:async';
import 'dart:io' as io show Platform;
import 'dart:ui';

import 'package:flutter/services.dart';

import '../../generated/platform_constants.dart';
import '../../push_notifications/src/push_notification_events.dart';
import '../../push_notifications/src/remote_message.dart';
import '../platform.dart';
import 'background_android_isolate_platform.dart';

class PushNotificationEventsNative implements PushNotificationEvents {
  VoidCallback? onOpenSettingsHandler;
  Future<bool> Function(RemoteMessage message)?
      onShowNotificationInForegroundHandler;
  StreamController<RemoteMessage> onMessageStreamController =
      StreamController();

  /// Controller used to indicate notification was tapped
  StreamController<RemoteMessage> onNotificationTapStreamController =
      StreamController();

  @override
  Future<RemoteMessage?> get notificationTapLaunchedAppFromTerminated =>
      Platform.methodChannel.invokeMethod(
          PlatformMethod.pushNotificationTapLaunchedAppFromTerminated);

  @override
  Stream<RemoteMessage> get onMessage => onMessageStreamController.stream;

  @override
  Stream<RemoteMessage> get onNotificationTap =>
      onNotificationTapStreamController.stream;

  @override
  void setOnOpenSettings(VoidCallback callback) {
    onOpenSettingsHandler = callback;
  }

  @override
  void setOnShowNotificationInForeground(
      Future<bool> Function(RemoteMessage message) callback) {
    onShowNotificationInForegroundHandler = callback;
  }

  /// An internal method that is called from the Platform side to check if the user
  /// wants notifications to be shown when the app is in the foreground.
  Future<bool> showNotificationInForeground(RemoteMessage message) async {
    if (onShowNotificationInForegroundHandler == null) {
      return false;
    }
    return onShowNotificationInForegroundHandler!(message);
  }

  BackgroundMessageHandler? _onBackgroundMessage;

  /// Implementation of setOnBackgroundMessage. For more documentation,
  /// see [PushNotificationEvents.setOnBackgroundMessage]
  void setOnBackgroundMessage(BackgroundMessageHandler handler) async {
    _onBackgroundMessage = handler;
    if (io.Platform.isAndroid) {
      await BackgroundIsolateAndroidPlatform.methodChannel
          .invokeMethod(PlatformMethod.pushSetOnBackgroundMessage);
    }
  }

  /// Handles a RemoteMessage passed from the platform side.
  void handleBackgroundMessage(RemoteMessage remoteMessage) {
    if (_onBackgroundMessage != null) {
      _onBackgroundMessage!(remoteMessage);
    } else {
      // ignore:avoid_print
      print('Received RemoteMessage but no handler was set. '
          'RemoteMessage.data: ${remoteMessage.data}. '
          'RemoteMessage.notification: ${remoteMessage.notification}. '
          'Set `ably.Push.notificationEvents.setOnBackgroundMessage()`.');
    }
  }

  void close() {
    onMessageStreamController.close();
    onNotificationTapStreamController.close();
  }
}
