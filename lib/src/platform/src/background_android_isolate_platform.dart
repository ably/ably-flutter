import 'package:flutter/services.dart';

import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../platform.dart';
import '../platform_internal.dart';

/// Manages the communication with Android Platform, in the case where
/// this dart side is an isolate launched by the Android Platform explicitly
/// for background messaging.
///
/// This method call handler is used to receive messages from Android side.
/// The platform methods invoked on Platform/ android side will only be
/// called when a separate isolate is launched by the app, not for apps
/// launched with Activity.
class BackgroundIsolateAndroidPlatform {
  /// Instantiates if required.
  factory BackgroundIsolateAndroidPlatform() {
    _platform ??= BackgroundIsolateAndroidPlatform._internal();
    return _platform!;
  }

  static BackgroundIsolateAndroidPlatform? _platform;

  BackgroundIsolateAndroidPlatform._internal() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.pushOnBackgroundMessage:
          return _onPushBackgroundMessage(call.arguments as RemoteMessage);
        default:
          throw PlatformException(
              code: 'invalid_method', message: 'No such method ${call.method}');
      }
    });
  }

  /// A method channel used to communicate with the user's app isolate
  /// we explicitly launched when a RemoteMessage is received. Used only on Android.
  static final MethodChannel methodChannel =
      MethodChannel('io.ably.flutter.plugin.background', Platform.codec);

  final PushNotificationEventsNative _pushNotificationEvents =
      PushNative.notificationEvents as PushNotificationEventsNative;

  Future<Object?> _onPushBackgroundMessage(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.handleBackgroundMessage(remoteMessage);
  }
}
