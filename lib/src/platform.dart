import 'dart:async';

import 'package:ably_flutter_plugin/src/generated/platformconstants.dart' show PlatformMethod;
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

import 'codec.dart';


/// instance of [StandardMethodCodec] with custom [MessageCodec] for
/// exchanging Ably types with platform via platform channels
/// viz., [MethodChannel] and [StreamsChannel]
StandardMethodCodec codec = StandardMethodCodec(Codec());

/// instance of method channel to interact with android/ios code
final MethodChannel methodChannel = MethodChannel('io.ably.flutter.plugin', codec);

/// instance of method channel to listen to android/ios events
final StreamsChannel streamsChannel = StreamsChannel('io.ably.flutter.stream', codec);


bool _initialized = false;

void _init(){
  methodChannel.invokeMethod(PlatformMethod.registerAbly).then((_){
    _initialized = true;
  });
}

/// Initializing ably on platform side by invoking `register` platform method.
/// Register will clear any stale instances on platform.
Future _initialize() async {
  if(_initialized) return;
  _init();
  // if `_initialized` is false => initialization is in progress.
  // Let's wait for 10ms and retry. If the total time exceeds 2 seconds,
  // a TimeoutException is raised
  //
  // this is required as many asynchronous `_initialize` calls
  // will be invoked from different Ably instances
  while(true){
    bool _registrationFailed = false;
    Future.delayed(Duration(seconds: 2), (){
      _registrationFailed = true;
    });
    await Future.delayed(Duration(milliseconds: 10));
    if(_registrationFailed){
      throw TimeoutException("Handle aquiring timed out");
    }
    if(_initialized) return;
  }
}

Future<T> invoke<T>(String method, [dynamic arguments]) async {
  await _initialize();
  return await methodChannel.invokeMethod<T>(method, arguments);
}
