import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

/// @nodoc
/// Used to communicate between Dart and native platforms
/// holds reference to [MethodChannel] and exposes methods used to invoke
/// platform calls and listen to platform data streams
class Platform {
  Platform._internal({MethodChannel? methodChannel}) {
    _methodChannel = methodChannel;
    if (methodChannel == null) {
      _methodChannel = MethodChannel('io.ably.flutter.plugin', _codec);
    }
    _streamsChannel = StreamsChannel('io.ably.flutter.stream', _codec);
    AblyMethodCallHandler(_methodChannel!);
    BackgroundIsolateAndroidPlatform().setupCallHandler();
    invokePlatformMethod<void>(PlatformMethod.resetAblyClients);
  }

  static Platform? _platform;

  /// @nodoc
  /// Singleton instance of Platform
  factory Platform({MethodChannel? methodChannel}) =>
      _platform ??= Platform._internal(methodChannel: methodChannel);

  /// @nodoc
  /// instance of [StandardMethodCodec] with custom [MessageCodec] for
  /// exchanging Ably types with platform via platform channels
  /// viz., [MethodChannel] and [StreamsChannel]
  final StandardMethodCodec _codec = StandardMethodCodec(Codec());

  /// @nodoc
  /// instance of method channel to interact with android/ios code
  MethodChannel? _methodChannel;

  /// @nodoc
  /// instance of method channel to listen to android/ios events
  late final StreamsChannel? _streamsChannel;

  /// @nodoc
  /// Call a platform method which may return null/void as a result
  Future<T?> invokePlatformMethod<T>(String method,
      [AblyMessage<Map<String, dynamic>>? arguments]) async {
    try {
      // If argument is null, pass an empty [AblyMessage], because codec fails
      // if argument value is null
      final methodArguments = arguments ?? AblyMessage.empty();
      return await _methodChannel!.invokeMethod<T>(method, methodArguments);
    } on PlatformException catch (platformException) {
      // Convert some PlatformExceptions into AblyException
      if (platformException.details is ErrorInfo) {
        throw AblyException.fromPlatformException(platformException);
      } else {
        rethrow;
      }
    }
  }

  /// @nodoc
  /// Call a platform method which always provides a non-null result
  Future<T> invokePlatformMethodNonNull<T>(String method,
      [AblyMessage<Map<String, dynamic>>? arguments]) async {
    final result = await invokePlatformMethod<T>(method, arguments);
    if (result == null) {
      throw AblyException(
          message: 'invokePlatformMethodNonNull("$method") platform '
              'method unexpectedly returned a null value.');
    } else {
      return result;
    }
  }

  /// @nodoc
  /// Call a platform method which always provides an observable stream
  /// of data as a result
  Stream<T> receiveBroadcastStream<T>(String methodName, int handle,
          [final Object? payload]) =>
      _streamsChannel!.receiveBroadcastStream<T>(
        AblyMessage(
          message: AblyEventMessage(
            eventName: methodName,
            message: payload,
          ),
          handle: handle,
        ),
      );
}
