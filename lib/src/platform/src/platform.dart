import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

class Platform {
  Platform._internal({MethodChannel? methodChannel}) {
    _methodChannel = methodChannel;
    if (methodChannel == null) {
      _methodChannel = MethodChannel('io.ably.flutter.plugin', _codec);
    }
    _streamsChannel = StreamsChannel('io.ably.flutter.stream', _codec);
    AblyMethodCallHandler(_methodChannel!);
    BackgroundIsolateAndroidPlatform().setupCallHandler();
    invokePlatformMethod(PlatformMethod.resetAblyClients);
  }

  static Platform? _platform;

  /// Singleton instance of Platform
  factory Platform({MethodChannel? methodChannel}) =>
      _platform ??= Platform._internal(methodChannel: methodChannel);

  /// instance of [StandardMethodCodec] with custom [MessageCodec] for
  /// exchanging Ably types with platform via platform channels
  /// viz., [MethodChannel] and [StreamsChannel]
  final StandardMethodCodec _codec = StandardMethodCodec(Codec());

  /// instance of method channel to interact with android/ios code
  MethodChannel? _methodChannel;

  /// instance of method channel to listen to android/ios events
  late final StreamsChannel? _streamsChannel;

  Future<T?> invokePlatformMethod<T>(String method, [Object? arguments]) async {
    try {
      return await _methodChannel!.invokeMethod<T>(method, arguments);
    } on PlatformException catch (platformException) {
      // Convert some PlatformExceptions into AblyException
      if (platformException.details is ErrorInfo) {
        throw AblyException.fromPlatformException(platformException);
      } else {
        rethrow;
      }
    }
  }

  /// Call a platform method which always provides a result.
  Future<T> invokePlatformMethodNonNull<T>(String method,
      [Object? arguments]) async {
    final result = await invokePlatformMethod<T>(method, arguments);
    if (result == null) {
      throw AblyException(
          message: 'invokePlatformMethodNonNull("$method") platform '
              'method unexpectedly returned a null value.');
    } else {
      return result;
    }
  }

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
