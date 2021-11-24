import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// Manages the communication with Android Platform, in the case where
/// this dart side is an isolate launched by the Android Platform explicitly
/// for background messaging.
///
/// This method call handler is used to receive messages from Android side.
/// The platform methods invoked on Platform/ android side will only be
/// called when a separate isolate is launched by the app, not for apps
/// launched with Activity.
class BackgroundIsolateAndroidPlatform {
  BackgroundIsolateAndroidPlatform._internal();

  /// Start listening to messages from Java side.
  void setupCallHandler() {
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case PlatformMethod.pushOnBackgroundMessage:
          return _onPushBackgroundMessage(call.arguments as RemoteMessage);
        default:
          throw PlatformException(
              code: 'invalid_method', message: 'No such method ${call.method}');
      }
    });
  }

  static final BackgroundIsolateAndroidPlatform _platform =
      BackgroundIsolateAndroidPlatform._internal();

  /// Singleton instance of BackgroundIsolateAndroidPlatform
  factory BackgroundIsolateAndroidPlatform() => _platform;

  /// A method channel used to communicate with the user's app isolate
  /// we explicitly launched when a RemoteMessage is received.
  /// Used only on Android.
  final MethodChannel _methodChannel = MethodChannel(
      'io.ably.flutter.plugin.background', StandardMethodCodec(Codec()));

  final PushNotificationEventsNative _pushNotificationEvents =
      PushNative.notificationEvents as PushNotificationEventsNative;

  Future<Object?> _onPushBackgroundMessage(RemoteMessage remoteMessage) async {
    _pushNotificationEvents.handleBackgroundMessage(remoteMessage);
  }

  Future<T?> invokeMethod<T>(String method, [arguments]) async =>
      _methodChannel.invokeMethod<T>(method, arguments);
}
