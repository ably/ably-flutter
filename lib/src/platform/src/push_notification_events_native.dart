import 'dart:async';
import 'dart:io' as io show Platform;
import 'dart:ui';

import '../../generated/platform_constants.dart';
import '../../push_notifications/src/push_notification_events.dart';
import '../../push_notifications/src/remote_message.dart';
import '../platform.dart';

class PushNotificationEventsNative implements PushNotificationEvents {
  Future<ForegroundNotificationConfiguration> Function(RemoteMessage message)?
      onShowNotificationInForegroundHandler;
  StreamController<RemoteMessage> onMessageStreamController =
      StreamController();
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
  void setOnShowNotificationInForeground(
      Future<ForegroundNotificationConfiguration> Function(
              RemoteMessage message)
          callback) {
    onShowNotificationInForegroundHandler = callback;
  }

  Future<ForegroundNotificationConfiguration> showNotificationInForeground(
      RemoteMessage message) async {
    if (onShowNotificationInForegroundHandler == null) {
      return ForegroundNotificationConfiguration();
    }
    return onShowNotificationInForegroundHandler!(message);
  }

  BackgroundMessageHandler? _onBackgroundMessage = null;

  set onBackgroundMessage(BackgroundMessageHandler handler) {
    if (io.Platform.isAndroid) {
      final handlerHandle = PluginUtilities.getCallbackHandle(handler);
      if (handlerHandle == null) {
        // TODO throw an error because the user did not set it to a top level function or something else.
      }
      Platform.methodChannel.invokeMethod(
          PlatformMethod.pushSetOnBackgroundMessage,
          handlerHandle!.toRawHandle());
    } else {
      // Don't set it for Android, since we don't want to call it on the dart side.
      // This is because we can only call it on the dart side in some cases, and
      // it's simpler to create a new isolate every time.
      // Instead, an isolate will run the callback
      // TODO consider just creating an isolate and using it forever. Or caching it
      //  There would be upfront cost but not regular costs.
      _onBackgroundMessage = handler;
    }
  }

  void handleBackgroundMessage(RemoteMessage remoteMessage) {
    if (_onBackgroundMessage != null) {
      _onBackgroundMessage!(remoteMessage);
    } else {
      //  TODO throw an exception, so users knows that their message wasn't handled
    }
  }
}
