import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

class Platform {
  Platform._internal() {
    AblyMethodCallHandler(methodChannel);
    BackgroundIsolateAndroidPlatform().setupCallHandler();
  }

  static final Platform _platform = Platform._internal();

  /// Singleton instance of Platform
  factory Platform() => _platform;

  /// instance of [StandardMethodCodec] with custom [MessageCodec] for
  /// exchanging Ably types with platform via platform channels
  /// viz., [MethodChannel] and [StreamsChannel]
  final StandardMethodCodec _codec = StandardMethodCodec(Codec());

  /// instance of method channel to interact with android/ios code
  late final MethodChannel methodChannel =
      MethodChannel('io.ably.flutter.plugin', _codec);

  /// instance of method channel to listen to android/ios events
  late final StreamsChannel _streamsChannel =
      StreamsChannel('io.ably.flutter.stream', _codec);

  /// This field will reset to true when the state is reset. This allows us to
  /// if an app has been restarted, or a hot restart (not hot reload) has
  /// happened.
  bool _shouldResetAblyClients = true;

  /// Clears instances on the Platform side
  ///
  /// Resets Ably clients and sets up
  Future<void> _resetAblyPlatform() async {
    await methodChannel.invokeMethod(PlatformMethod.resetAblyClients);
    _shouldResetAblyClients = false;
  }

  ///
  Future<T?> invokePlatformMethod<T>(String method, [Object? arguments]) async {
    if (_shouldResetAblyClients) {
      await _resetAblyPlatform();
      return methodChannel.invokeMethod<T>(method, arguments);
    }
    try {} on PlatformException catch (pe) {
      if (pe.details is ErrorInfo) {
        throw AblyException.fromPlatformException(pe);
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
      throw AblyException('invokePlatformMethodNonNull("$method") platform '
          'method unexpectedly returned a null value.');
    } else {
      return result;
    }
  }

  Stream<T> receiveBroadcastStream<T>(String methodName, int handle,
          [final Object? payload]) =>
      _streamsChannel.receiveBroadcastStream<T>(
        AblyMessage(
          AblyEventMessage(methodName, payload),
          handle: handle,
        ),
      );
}
