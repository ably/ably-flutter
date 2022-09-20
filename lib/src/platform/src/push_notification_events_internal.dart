import 'dart:async';
import 'dart:io' as io show Platform;
import 'dart:ui';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// package-private implementation of [PushNotificationEvents]
/// END LEGACY DOCSTRING
class PushNotificationEventsInternal implements PushNotificationEvents {
  /// BEGIN LEGACY DOCSTRING
  /// Invoked when pushOpenSettingsFor platform method is called
  /// END LEGACY DOCSTRING
  VoidCallback? onOpenSettingsHandler;

  /// BEGIN LEGACY DOCSTRING
  /// Invoked when pushOnShowNotificationInForeground platform method is called
  /// END LEGACY DOCSTRING
  Future<bool> Function(RemoteMessage message)?
      onShowNotificationInForegroundHandler;

  /// BEGIN LEGACY DOCSTRING
  /// Exposes stream of received [RemoteMessage] objects
  /// New message is emitted after pushOnMessage platform method is called
  /// END LEGACY DOCSTRING
  StreamController<RemoteMessage> onMessageStreamController =
      StreamController();

  /// BEGIN LEGACY DOCSTRING
  /// Controller used to indicate notification was tapped
  /// END LEGACY DOCSTRING
  StreamController<RemoteMessage> onNotificationTapStreamController =
      StreamController();

  BackgroundMessageHandler? _onBackgroundMessage;

  @override
  Future<RemoteMessage?> get notificationTapLaunchedAppFromTerminated =>
      Platform().invokePlatformMethod<RemoteMessage>(
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

  /// BEGIN LEGACY DOCSTRING
  /// An internal method that is called from the Platform side to check if the
  /// user wants notifications to be shown when the app is in the foreground.
  /// END LEGACY DOCSTRING
  Future<bool> showNotificationInForeground(RemoteMessage message) async {
    if (onShowNotificationInForegroundHandler == null) {
      return false;
    }
    return onShowNotificationInForegroundHandler!(message);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Implementation of setOnBackgroundMessage. For more documentation,
  /// see [PushNotificationEvents.setOnBackgroundMessage]
  /// END LEGACY DOCSTRING
  @override
  Future<void> setOnBackgroundMessage(BackgroundMessageHandler handler) async {
    _onBackgroundMessage = handler;
    if (io.Platform.isAndroid) {
      // Inform Android side that the Flutter application
      // is ready to receive push messages.
      await BackgroundIsolateAndroidPlatform().invokeMethod<void>(
        PlatformMethod.pushBackgroundFlutterApplicationReadyOnAndroid,
      );
    }
  }

  /// BEGIN LEGACY DOCSTRING
  /// Handles a RemoteMessage passed from the platform side.
  /// END LEGACY DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// Used to close internal [StreamController] instances
  /// END LEGACY DOCSTRING
  // FIXME: This method is not called anywhere
  // See: https://github.com/ably/ably-flutter/issues/382
  void close() {
    onMessageStreamController.close();
    onNotificationTapStreamController.close();
  }
}
