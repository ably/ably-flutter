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

  /// This field will reset to true when the state is reset. This allows us to
  /// if an app has been restarted, or a hot restart (not hot reload) has
  /// happened.
  static bool _shouldResetAblyClients = true;

  /// Clears instances on the Platform side
  static Future<void> _resetOldAblyClients() async {
    if (_shouldResetAblyClients) {
      AblyMethodCallHandler(methodChannel);
      BackgroundIsolateAndroidPlatform();
      await methodChannel.invokeMethod(PlatformMethod.resetAblyClients);
      _shouldResetAblyClients = false;
    }
  }

  /// invokes a platform [method] with [arguments]
  ///
  /// calls [_resetOldAblyClients] before invoking any method to handle any
  /// cleanup tasks that are especially required while performing hot-restart
  /// (as hot-restart does not automatically reset platform instances)
  static Future<T?> invokePlatformMethod<T>(String method,
      [Object? arguments]) async {
    await _resetOldAblyClients();
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
    final result = await invokePlatformMethod<T>(method, arguments);
    if (result == null) {
      throw AblyException('invokePlatformMethodNonNull("$method") platform '
          'method unexpectedly returned a null value.');
    } else {
      return result;
    }
  }
}
