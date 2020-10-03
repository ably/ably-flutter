import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/platform.dart' as platform;
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'streams_channel.dart';

/// An object which has a live counterpart in the Platform client library SDK,
/// where that live counterpart is held as a strong reference by the plugin
/// implementation.
abstract class PlatformObject {
  static const _acquireHandleTimeout = Duration(seconds: 2);
  Future<int> _handle;
  int _handleValue; // Only for logging. Otherwise use _handle instead.

  PlatformObject() {
    _handle = _acquireHandle();
  }

  @override
  String toString() => 'Ably Platform Object $_handleValue';

  Future<int> createPlatformInstance();

  Future<int> get handle async => _handle ??= _acquireHandle();

  Future<int> _acquireHandle() =>
      createPlatformInstance().timeout(_acquireHandleTimeout, onTimeout: () {
        _handle = null;
        throw TimeoutException(
            'Acquiring handle timed out.', _acquireHandleTimeout);
      }).then((value) => _handleValue = value);

  MethodChannel get methodChannel => platform.methodChannel;

  StreamsChannel get eventChannel => platform.streamsChannel;

  /// invoke platform method channel without AblyMessage encapsulation
  @protected
  Future<T> invokeRaw<T>(final String method, [final Object arguments]) async {
    return await platform.invoke<T>(method, arguments);
  }

  /// invoke platform method channel with AblyMessage encapsulation
  @protected
  Future<T> invoke<T>(final String method, [final Object argument]) async {
    var _handle = await handle;
    final message = (null != argument)
        ? AblyMessage(AblyMessage(argument, handle: _handle))
        : AblyMessage(_handle);
    return await invokeRaw<T>(method, message);
  }

  Future<Stream<dynamic>> _listen(final String eventName,
      [final Object payload]) async {
    return eventChannel.receiveBroadcastStream(AblyMessage(
        AblyEventMessage(eventName, payload),
        handle: await handle));
  }

  /// Listen for events
  @protected
  Stream<dynamic> listen(final String method, [final Object payload]) {
    var controller = StreamController<dynamic>();
    _listen(method, payload).then(controller.addStream);
    return controller.stream;
  }
}
