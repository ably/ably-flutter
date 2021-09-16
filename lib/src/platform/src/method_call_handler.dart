import 'package:ably_flutter/ably_flutter.dart';
import 'package:flutter/services.dart';

import '../../authentication/authentication.dart';
import '../../error/error.dart';
import '../../generated/platform_constants.dart';
import '../platform.dart';
import '../platform_internal.dart';
import 'ably_message.dart';
import 'push_activation_events_native.dart';
import 'push_notification_events_native.dart';

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
      throw AblyException('invalid message handle ${message.handle}');
    }
    final callbackResponse = await rest.options.authCallback!(tokenParams);
    Future.delayed(Duration.zero, rest.authUpdateComplete);
    return callbackResponse;
  }

  bool _realtimeAuthInProgress = false;

  /// handles auth callback for realtime instances
  Future<Object?> onRealtimeAuthCallback(AblyMessage? message) async {
    if (_realtimeAuthInProgress) {
      return null;
    }
    _realtimeAuthInProgress = true;
    final tokenParams = message!.message as TokenParams;
    final realtime = realtimeInstances[message.handle];
    if (realtime == null) {
      throw AblyException('invalid message handle ${message.handle}');
    }
    final callbackResponse = await realtime.options.authCallback!(tokenParams);
    Future.delayed(Duration.zero, realtime.authUpdateComplete);
    _realtimeAuthInProgress = false;
    return callbackResponse;
  }

  PushActivationEventsNative _pushActivationEvents =
      PushNative.activationEvents as PushActivationEventsNative;
  PushNotificationEventsNative _pushNotificationEvents =
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
    _pushNotificationEvents.onNotificationTapStreamController.add(remoteMessage);
  }
}
