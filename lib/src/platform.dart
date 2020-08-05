import 'dart:async';

import 'package:ably_flutter_plugin/src/generated/platformconstants.dart' show PlatformMethod;
import 'package:ably_flutter_plugin/src/method_call_handler.dart';
import 'package:flutter/services.dart';

import 'codec.dart';
import 'impl/streams_channel.dart';


/// instance of [StandardMethodCodec] with custom [MessageCodec] for
/// exchanging Ably types with platform via platform channels
/// viz., [MethodChannel] and [StreamsChannel]
StandardMethodCodec codec = StandardMethodCodec(Codec());

/// instance of method channel to interact with android/ios code
final MethodChannel methodChannel = MethodChannel('io.ably.flutter.plugin', codec);

/// instance of method channel to listen to android/ios events
final StreamsChannel streamsChannel = StreamsChannel('io.ably.flutter.stream', codec);

/// Initializing ably on platform side by invoking `register` platform method.
/// Register will clear any stale instances on platform.
const _initializeTimeout = Duration(seconds: 2);
Future _initializer;
Future _initialize() async {
  AblyMethodCallHandler(methodChannel);
  return _initializer ??=  methodChannel.invokeMethod(PlatformMethod.registerAbly)
    .timeout(_initializeTimeout, onTimeout: () {
    _initializer = null;
    throw TimeoutException('Initialization timed out.', _initializeTimeout);
  });
}

Future<T> invoke<T>(String method, [dynamic arguments]) async {
  await _initialize();
  return await methodChannel.invokeMethod<T>(method, arguments);
}
