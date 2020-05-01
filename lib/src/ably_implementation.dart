import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/interface.dart';
import 'package:flutter/services.dart';

import '../ably.dart';
import 'codec.dart';
import 'impl/platform_object.dart';
import 'impl/realtime.dart';
import 'impl/rest/rest.dart';

///Extension to extract string name from PlatformMethod
extension on PlatformMethod {
  String toName() {
    // https://stackoverflow.com/a/59308734/392847
    return this.toString().split('.').last;
  }
}

/// Ably plugin implementation
/// Single point of interaction that exposes all necessary APIs to ably objects
class AblyImplementation implements Ably {

  /// instance of method channel to interact with android/ios code
  final MethodChannel methodChannel;

  /// Storing all platform objects, for easy references/cleanup
  final List<PlatformObject> _platformObjects = [];

  /// ably handle, created from platform's end
  /// This makes sure we are accessing the right Ably instance on platform
  /// as users can create multiple [Ably] instances
  int _handle;

  factory AblyImplementation() {
    /// Uses our custom message codec so that we can pass Ably types to the
    /// platform implementations.
    final methodChannel = MethodChannel('ably_flutter_plugin', StandardMethodCodec(Codec()));
    return AblyImplementation._constructor(methodChannel);
  }

  AblyImplementation._constructor(this.methodChannel);

  /// Registering instance with ably.
  /// On registration, older ably instance id destroyed!
  /// TODO check if this is desired behavior in case if 2 different ably instances are created in app
  Future<int> _register() async => (null != _handle) ? _handle : _handle = await methodChannel.invokeMethod(PlatformMethod.register.toName());

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
        methodChannel,
        await methodChannel.invokeMethod(
            PlatformMethod.createRealtimeWithOptions.toName(),
            message
        )
    );
    _platformObjects.add(r);
    return r;
  }

  @override
  Future<Rest> createRestWithKey(final String key) async => createRest(ClientOptions.fromKey(key));

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
        methodChannel,
        await methodChannel.invokeMethod(
            PlatformMethod.createRestWithOptions.toName(),
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
      await methodChannel.invokeMethod(PlatformMethod.getPlatformVersion.toName());

  @override
  Future<String> get version async =>
      await methodChannel.invokeMethod(PlatformMethod.getVersion.toName());
}
