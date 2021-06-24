import 'dart:async';

import 'package:flutter/services.dart';

import 'codec.dart';
import 'generated/platformconstants.dart' show PlatformMethod;
import 'impl/streams_channel.dart';
import 'method_call_handler.dart';
import 'spec/common.dart' show ErrorInfo, AblyException;
import 'spec/constants.dart';

/// instance of [StandardMethodCodec] with custom [MessageCodec] for
/// exchanging Ably types with platform via platform channels
/// viz., [MethodChannel] and [StreamsChannel]
StandardMethodCodec codec = StandardMethodCodec(Codec());

/// instance of method channel to interact with android/ios code
final MethodChannel methodChannel =
    MethodChannel('io.ably.flutter.plugin', codec);

/// instance of method channel to listen to android/ios events
final StreamsChannel streamsChannel =
    StreamsChannel('io.ably.flutter.stream', codec);

/// Initializing ably on platform side by invoking `register` platform method.
/// Register will clear any stale instances on platform.
Future? _initializer;

Future _initialize() async {
  if (_initializer == null) {
    AblyMethodCallHandler(methodChannel);
    _initializer = methodChannel
        .invokeMethod(PlatformMethod.registerAbly)
        .timeout(Timeouts.initializeTimeout, onTimeout: () {
      _initializer = null;
      throw TimeoutException(
        'Initialization timed out.',
        Timeouts.initializeTimeout,
      );
    });
  }
  return _initializer;
}

/// invokes a platform [method] with [arguments]
///
/// calls an [_initialize] method before invoking any method so as to handle
/// any cleanup tasks that are especially required while performing hot-restart
/// (as hot-restart is known to not clear any objects on platform side)
Future<T?> invokePlatformMethod<T>(String method, [Object? arguments]) async {
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
