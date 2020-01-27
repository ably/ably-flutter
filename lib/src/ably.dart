import 'dart:async';
import 'package:flutter/services.dart';
import 'package:ably_test_flutter_oldskool_plugin/ably.dart' as api;

const MethodChannel methodChannel = MethodChannel('ably_test_flutter_oldskool_plugin');

Future<String> get platformVersion async {
  return await methodChannel.invokeMethod('getPlatformVersion');
}

Future<String> get version async {
  return await methodChannel.invokeMethod('getVersion');
}

/// An object which has a live counterpart in the Platform client library SDK.
abstract class PlatformObject {
  final int handle;

  PlatformObject(this.handle);
}

class Realtime extends PlatformObject implements api.Realtime {
  /// Private constructor. https://stackoverflow.com/a/55143972/392847
  Realtime._(int handle) : super(handle);

  static Future<Realtime> create(final api.ClientOptions options) async {
    return Realtime._(await methodChannel.invokeMethod('createRealtimeWithOptions', options));
  }

  @override
  // TODO: implement channels
  api.Channels get channels => null;

  @override
  void close() {
    // TODO: implement close
  }

  @override
  void connect() {
    // TODO: implement connect
  }

  @override
  // TODO: implement connection
  api.Connection get connection => null;
}
