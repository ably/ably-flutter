import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// A representation of a Platform side instance (Android, iOS).
abstract class PlatformObject {
  Future<int>? _handle;
  final Platform _platform = Platform();
  int? _handleValue; // Only for logging. Otherwise use _handle instead.

  /// immediately instantiates an object on platform side by calling
  /// [createPlatformInstance] if [fetchHandle] is true,
  /// otherwise, platform instance will be created only when
  /// [createPlatformInstance] is explicitly called.
  PlatformObject({bool fetchHandle = true}) {
    if (fetchHandle) {
      _handle = _acquireHandle();
    }
  }

  @override
  String toString() => 'Ably Flutter PlatformObject with handle: $_handleValue';

  /// creates an instance of this object on platform side
  Future<int?> createPlatformInstance();

  /// returns [_handle] which will be same as handle on platform side
  ///
  /// if [_handle] is empty, it creates platform instance, acquires handle,
  /// updates [_handle] and returns it.
  Future<int> get handle async => _handle ??= _acquireHandle();

  Future<int> _acquireHandle() =>
      createPlatformInstance().then((value) => (_handleValue = value)!);

  /// invoke platform method channel without AblyMessage encapsulation
  @protected
  Future<T?> invokeRaw<T>(
    final String method, [
    final Object? arguments,
  ]) async =>
      _platform.invokePlatformMethod<T>(method, arguments);

  /// invoke platform method channel with AblyMessage encapsulation
  ///
  /// this is similar to [invoke], but ensures the response is not null
  Future<T> invokeRequest<T>(final String method,
      [final Object? argument]) async {
    final response = await invoke<T>(method, argument);
    if (response == null) {
      throw AblyException(
        'Platform communication error. Response cannot be null for $method',
      );
    } else {
      return response;
    }
  }

  /// invoke platform method channel with AblyMessage encapsulation
  /* FIXME(ikurek): This seems wrong - the structure is either
  {
      message: {
          message: argument,
          handle: handle,
          type: null
      },
      handle: null,
      type: null
   }

   or

   {
       message: handle,
       handle: null,
       type: null
   }

   Which means that the structure is wrong every time, but I can't
   understand why and it seems that iOS/Android code reads handle from
   message field, so I don't want to touch it now
  */
  Future<T?> invoke<T>(final String method, [final Object? argument]) async {
    final _handle = await handle;
    final message = (null != argument)
        ? AblyMessage(AblyMessage(argument, handle: _handle))
        : AblyMessage(_handle);
    return invokeRaw<T>(method, message);
  }

  /// Listen for events
  @protected
  Stream<T> listen<T>(final String method, [final Object? payload]) {
    // ignore: close_sinks, will be closed by listener
    final controller = StreamController<T>();
    handle
        .then((handle) =>
            _platform.receiveBroadcastStream<T>(method, handle, payload))
        .then(controller.addStream);
    return controller.stream;
  }
}
