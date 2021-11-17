import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// Handles method calls invoked from platform side to dart side
class AblyMethodCallHandler {
  /// creates instance with method channel and forwards calls respective
  /// instance methods: [onAuthCallback], [onRealtimeAuthCallback], etc
  AblyMethodCallHandler(MethodChannel channel) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.authCallback:
          return onAuthCallback(call.arguments as AblyMessage);
        case PlatformMethod.realtimeAuthCallback:
          return onRealtimeAuthCallback(call.arguments as AblyMessage?);
        case PlatformMethod.pushOnActivate:
          return _onPushOnActivate(call.arguments as ErrorInfo?);
        case PlatformMethod.pushOnDeactivate:
          return _onPushOnDeactivate(call.arguments as ErrorInfo?);
        case PlatformMethod.pushOnUpdateFailed:
          return _onPushOnUpdateFailed(call.arguments as ErrorInfo);
        case PlatformMethod.pushOnMessage:
          return _onPushOnMessage(call.arguments as RemoteMessage);
        case PlatformMethod.pushOnBackgroundMessage:
          return _onPushBackgroundMessage(call.arguments as RemoteMessage);
        case PlatformMethod.pushOnShowNotificationInForeground:
          return _pushNotificationEvents
              .showNotificationInForeground(call.arguments as RemoteMessage);
        case PlatformMethod.pushOnNotificationTap:
          return onNotificationTap(call.arguments as RemoteMessage);
        case PlatformMethod.pushOpenSettingsFor:
          return onOpenSettingsFor();
        default:
          throw PlatformException(
              code: 'invalid_method', message: 'No such method ${call.method}');
      }
    });
  }

  /// handles auth callback for rest instances
  Future<Object> onAuthCallback(AblyMessage message) async {
    final tokenParams = message.message as TokenParams;
    final rest = restInstances[message.handle];
    if (rest == null) {
      throw AblyException('AblyMethodCallHandler#onAuthCallback\'s '
          'realtime handle is ${message.handle}');
    }
    return rest.options.authCallback!(tokenParams);
  }

  /// handles auth callback for realtime instances
  Future<Object?> onRealtimeAuthCallback(AblyMessage? message) async {
    final tokenParams = message!.message as TokenParams;
    final realtime = realtimeInstances[message.handle];
    if (realtime == null) {
      throw AblyException('AblyMethodCallHandler#onRealtimeAuthCallback\'s '
          'realtime handle is ${message.handle}');
    }
    return realtime.options.authCallback!(tokenParams);
  }

  final PushActivationEventsNative _pushActivationEvents =
      PushNative.activationEvents as PushActivationEventsNative;
  final PushNotificationEventsNative _pushNotificationEvents =
      PushNative.notificationEvents as PushNotificationEventsNative;

  Future<Object?> _onPushOnActivate(ErrorInfo? error) async {
    _pushActivationEvents.onActivateStreamController.add(error);
    return null;
  }

  Future<Object?> _onPushOnDeactivate(ErrorInfo? error) async {
    _pushActivationEvents.onDeactivateStreamController.add(error);
    return null;
  }

  Future<Object?> _onPushOnUpdateFailed(ErrorInfo error) async {
    _pushActivationEvents.onUpdateFailedStreamController.add(error);
    return null;
  }

  Future<Object?> _onPushOnMessage(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.onMessageStreamController.add(remoteMessage);
  }

  Future<Object?> _onPushBackgroundMessage(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.handleBackgroundMessage(remoteMessage);
  }

  Future<Object?> onNotificationTap(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.onNotificationTapStreamController
        .add(remoteMessage);
  }

  Future<Object?> onOpenSettingsFor() async {
    if (_pushNotificationEvents.onOpenSettingsHandler != null) {
      _pushNotificationEvents.onOpenSettingsHandler!();
    }
  }
}
