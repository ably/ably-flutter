import 'dart:async';

import 'package:flutter/services.dart';

import 'codec.dart';
import 'generated/platformconstants.dart' show PlatformMethod;
import 'impl/streams_channel.dart';
import 'method_call_handler.dart';

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
const _initializeTimeout = Duration(seconds: 2);
Future _initializer;

Future _initialize() async {
  if (_initializer == null) {
    AblyMethodCallHandler(methodChannel);
    _initializer = methodChannel
        .invokeMethod(PlatformMethod.registerAbly)
        .timeout(_initializeTimeout, onTimeout: () {
      _initializer = null;
      throw TimeoutException('Initialization timed out.', _initializeTimeout);
    });
  }
  return _initializer;
}

Future<T> invoke<T>(String method, [Object arguments]) async {
  await _initialize();
  return await methodChannel.invokeMethod<T>(method, arguments);
}
