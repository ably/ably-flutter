import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// BEGIN LEGACY DOCSTRING
/// @nodoc
/// Manages the communication with Android Platform, in the case where
/// this dart side is an isolate launched by the Android Platform explicitly
/// for background messaging.
///
/// This method call handler is used to receive messages from Android side.
/// The platform methods invoked on Platform/ android side will only be
/// called when a separate isolate is launched by the app, not for apps
/// launched with Activity.
/// END LEGACY DOCSTRING
class BackgroundIsolateAndroidPlatform {
  BackgroundIsolateAndroidPlatform._internal();

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Start listening to messages from Java side.
  /// END LEGACY DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Singleton instance of BackgroundIsolateAndroidPlatform
  /// END LEGACY DOCSTRING
  factory BackgroundIsolateAndroidPlatform() => _platform;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// A method channel used to communicate with the user's app isolate
  /// we explicitly launched when a RemoteMessage is received.
  /// Used only on Android.
  /// END LEGACY DOCSTRING
  final MethodChannel _methodChannel = MethodChannel(
      'io.ably.flutter.plugin.background', StandardMethodCodec(Codec()));

  final PushNotificationEventsInternal _pushNotificationEvents =
      Push.notificationEvents as PushNotificationEventsInternal;

  Future<void> _onPushBackgroundMessage(RemoteMessage remoteMessage) async =>
      _pushNotificationEvents.handleBackgroundMessage(remoteMessage);

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Equivalent of [Platform.invokePlatformMethod] which cannot be used here
  /// because we may not be able to acquire [Platform] instance here, so we
  /// need to use a raw [MethodChannel] communication
  /// END LEGACY DOCSTRING
  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async =>
      _methodChannel.invokeMethod<T>(method, arguments);
}
