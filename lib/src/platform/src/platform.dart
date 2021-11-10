import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';
import 'package:flutter/services.dart';

class Platform {
  /// instance of [StandardMethodCodec] with custom [MessageCodec] for
  /// exchanging Ably types with platform via platform channels
  /// viz., [MethodChannel] and [StreamsChannel]
  static StandardMethodCodec codec = StandardMethodCodec(Codec());

  /// instance of method channel to interact with android/ios code
  static final MethodChannel methodChannel =
      MethodChannel('io.ably.flutter.plugin', codec);

  /// instance of method channel to listen to android/ios events
  static final StreamsChannel streamsChannel =
      StreamsChannel('io.ably.flutter.stream', codec);

  /// Initializing ably on platform side by invoking `register` platform method.
  /// Register will clear any stale instances on platform.
  static Future? _initializer;

  static Future _initialize() async {
    if (_initializer == null) {
      AblyMethodCallHandler(methodChannel);
      _initializer = methodChannel.invokeMethod(PlatformMethod.registerAbly);
    }
    return _initializer;
  }

  /// invokes a platform [method] with [arguments]
  ///
  /// calls an [_initialize] method before invoking any method to handle any
  /// cleanup tasks that are especially required while performing hot-restart
  /// (as hot-restart is known to not clear any objects on platform side)
  static Future<T?> invokePlatformMethod<T>(String method,
      [Object? arguments]) async {
    await _initialize();
    try {
      return await methodChannel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (pe) {
      if (pe.details is ErrorInfo) {
        throw AblyException.fromPlatformException(pe);
      } else {
        rethrow;
      }
    }
  }

  /// Call a platform method which always provides a result.
  static Future<T> invokePlatformMethodNonNull<T>(String method,
      [Object? arguments]) async {
    await _initialize();
    try {
      final result = await methodChannel.invokeMethod<T>(method, arguments);
      if (result == null) {
        throw AblyException('invokePlatformMethodNonNull("$method") platform '
            'method unexpectedly returned a null value.');
      } else {
        return result;
      }
    } on PlatformException catch (pe) {
      if (pe.details is ErrorInfo) {
        throw AblyException.fromPlatformException(pe);
      } else {
        rethrow;
      }
    }
  }
}
