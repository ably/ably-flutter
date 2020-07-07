import 'dart:async';

import 'package:ably_flutter_plugin/src/generated/platformconstants.dart' show PlatformMethod;
import 'package:ably_flutter_plugin/src/interface.dart';
import 'package:flutter/services.dart';
import 'package:streams_channel/streams_channel.dart';

import 'codec.dart';
import 'impl/platform_object.dart';
import 'impl/realtime/realtime.dart';
import 'impl/rest/rest.dart';
import 'spec/spec.dart' as spec;


/// Ably plugin implementation
/// Single point of interaction that exposes all necessary APIs to ably objects
class AblyImplementation implements AblyLibrary {

  /// instance of method channel to interact with android/ios code
  final MethodChannel methodChannel;

  /// instance of method channel to listen to android/ios events
  final StreamsChannel streamsChannel;

  /// Storing all platform objects, for easy references/cleanup
  final List<PlatformObject> _platformObjects = [];

  factory AblyImplementation() {
    /// Uses our custom message codec so that we can pass Ably types to the
    /// platform implementations.
    StandardMethodCodec codec = StandardMethodCodec(Codec());
    return AblyImplementation._constructor(
      MethodChannel('io.ably.flutter.plugin', codec),
      StreamsChannel('io.ably.flutter.stream', codec)
    );
  }

  bool _initialized = false;

  AblyImplementation._constructor(this.methodChannel, this.streamsChannel);

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

  @override
  spec.Realtime Realtime({
    spec.ClientOptions options,
    final String key
  }) {
    // TODO options.authCallback
    // TODO options.logHandler
    final r = RealtimePlatformObject(options: options, key: key);
    _platformObjects.add(r);
    return r;
  }

  @override
  spec.Rest Rest({
    spec.ClientOptions options,
    final String key
  }) {
    // TODO options.authCallback
    // TODO options.logHandler
    final r = RestPlatformObject(options: options, key: key);
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<String> get platformVersion async => await invoke(PlatformMethod.getPlatformVersion);

  @override
  Future<String> get version async => await invoke(PlatformMethod.getVersion);

}
