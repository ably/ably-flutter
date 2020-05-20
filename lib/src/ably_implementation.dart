import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/interface.dart';
import 'package:flutter/services.dart';
import 'package:ably_flutter_plugin/src/gen/platformconstants.dart' show PlatformMethod;
import 'package:streams_channel/streams_channel.dart';
import '../ably.dart';
import 'codec.dart';
import 'impl/platform_object.dart';
import 'impl/realtime/realtime.dart';
import 'impl/rest/rest.dart';

/// Ably plugin implementation
/// Single point of interaction that exposes all necessary APIs to ably objects
class AblyImplementation implements Ably {

  /// instance of method channel to interact with android/ios code
  final MethodChannel methodChannel;

  /// instance of method channel to listen to android/ios events
  final StreamsChannel streamsChannel;

  /// Storing all platform objects, for easy references/cleanup
  final List<PlatformObject> _platformObjects = [];

  /// ably handle, created from platform's end
  /// This makes sure we are accessing the right Ably instance on platform
  /// as users can create multiple [Ably] instances
  int _handle;

  factory AblyImplementation() {
    /// Uses our custom message codec so that we can pass Ably types to the
    /// platform implementations.
    StandardMethodCodec codec = StandardMethodCodec(Codec());
    return AblyImplementation._constructor(
        MethodChannel('io.ably.flutter.plugin', codec),
        StreamsChannel('io.ably.flutter.stream', codec)
    );
  }

  AblyImplementation._constructor(this.methodChannel, this.streamsChannel);

  /// Registering instance with ably.
  /// On registration, older ably instance id destroyed!
  /// TODO check if this is desired behavior in case if 2 different ably instances are created in app
  Future<int> _register() async => (null != _handle) ? _handle : _handle = await methodChannel.invokeMethod(PlatformMethod.registerAbly);

  @override
  Future<Realtime> createRealtime({
    ClientOptions options,
    final String key
  }) async {
    // TODO options.authCallback
    // TODO options.logHandler
    final handle = await _register();
    final message = AblyMessage(handle, options);
    final r = RealtimePlatformObject(
        handle,
        this,
        await methodChannel.invokeMethod(
            PlatformMethod.createRealtimeWithOptions,
            message
        ),
        options: options,
        key: key
    );
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<Rest> createRest({
    ClientOptions options,
    final String key
  }) async {
    // TODO options.authCallback
    // TODO options.logHandler
    final handle = await _register();
    final message = AblyMessage(handle, options);
    final r = RestPlatformObject(
        handle,
        this,
        await methodChannel.invokeMethod(
            PlatformMethod.createRestWithOptions,
            message
        ),
        options: options,
        key: key
    );
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<String> get platformVersion async =>
      await methodChannel.invokeMethod(PlatformMethod.getPlatformVersion);

  @override
  Future<String> get version async =>
      await methodChannel.invokeMethod(PlatformMethod.getVersion);
}
