import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// @nodoc
/// Handles method calls invoked from platform side to dart side
class AblyMethodCallHandler {
  /// @nodoc
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
          return _onNotificationTap(call.arguments as RemoteMessage);
        case PlatformMethod.pushOpenSettingsFor:
          return _onOpenSettingsFor();
        default:
          throw PlatformException(
              code: 'Received invalid method channel call from Platform side',
              message: 'No such method ${call.method}');
      }
    });
  }

  /// @nodoc
  /// handles auth callback for rest instances
  Future<Object> onAuthCallback(AblyMessage<dynamic> message) async {
    final tokenParams = message.message as TokenParams;
    final rest = restInstances[message.handle];
    if (rest == null) {
      throw AblyException(
        message: "AblyMethodCallHandler#onAuthCallback's "
            'rest handle is ${message.handle}, and rest is $rest',
      );
    }
    return rest.options.authCallback!(tokenParams);
  }

  /// @nodoc
  /// handles auth callback for realtime instances
  Future<Object?> onRealtimeAuthCallback(AblyMessage<dynamic>? message) async {
    final tokenParams = message!.message as TokenParams;
    final realtime = realtimeInstances[message.handle];
    if (realtime == null) {
      throw AblyException(
        message: "AblyMethodCallHandler#onRealtimeAuthCallback's "
            'realtime handle is ${message.handle}, and realtime is $realtime',
      );
    }
    return realtime.options.authCallback!(tokenParams);
  }

  final PushActivationEventsInternal _pushActivationEvents =
      Push.activationEvents as PushActivationEventsInternal;
  final PushNotificationEventsInternal _pushNotificationEvents =
      Push.notificationEvents as PushNotificationEventsInternal;

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
    return null;
  }

  Future<Object?> _onPushBackgroundMessage(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.handleBackgroundMessage(remoteMessage);
    return null;
  }

  Future<Object?> _onNotificationTap(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.onNotificationTapStreamController
        .add(remoteMessage);
    return null;
  }

  Future<Object?> _onOpenSettingsFor() async {
    if (_pushNotificationEvents.onOpenSettingsHandler != null) {
      _pushNotificationEvents.onOpenSettingsHandler!();
    }
    return null;
  }
}
