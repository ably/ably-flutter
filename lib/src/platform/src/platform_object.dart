import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// A representation of a Platform side instance (Android, iOS).
/// END LEGACY DOCSTRING
abstract class PlatformObject {
  Future<int>? _handle;
  final Platform _platform = Platform();
  int? _handleValue; // Only for logging. Otherwise use _handle instead.

  /// BEGIN LEGACY DOCSTRING
  /// immediately instantiates an object on platform side by calling
  /// [createPlatformInstance] if [fetchHandle] is true,
  /// otherwise, platform instance will be created only when
  /// [createPlatformInstance] is explicitly called.
  /// END LEGACY DOCSTRING
  PlatformObject({bool fetchHandle = true}) {
    if (fetchHandle) {
      _handle = _acquireHandle();
    }
  }

  @override
  String toString() => 'Ably Flutter PlatformObject with handle: $_handleValue';

  /// BEGIN LEGACY DOCSTRING
  /// creates an instance of this object on platform side
  /// END LEGACY DOCSTRING
  Future<int?> createPlatformInstance();

  /// BEGIN LEGACY DOCSTRING
  /// returns [_handle] which will be same as handle on platform side
  ///
  /// if [_handle] is empty, it creates platform instance, acquires handle,
  /// updates [_handle] and returns it.
  /// END LEGACY DOCSTRING
  Future<int> get handle async => _handle ??= _acquireHandle();

  Future<int> _acquireHandle() =>
      createPlatformInstance().then((value) => (_handleValue = value)!);

  /// BEGIN LEGACY DOCSTRING
  /// invoke platform method channel without current handle
  /// this method should be protected since it's only used to cover edge
  /// case for creating rest and realtime instances
  /// END LEGACY DOCSTRING
  @protected
  Future<T?> invokeWithoutHandle<T>(final String method,
      [final Map<String, dynamic>? argument]) async {
    final message = AblyMessage(
      message: argument ?? {},
    );
    return _platform.invokePlatformMethod<T>(method, message);
  }

  /// BEGIN LEGACY DOCSTRING
  /// invoke platform method channel with provided handle, or
  /// current handle if [externalHandle] is not provided
  /// END LEGACY DOCSTRING
  Future<T?> invoke<T>(final String method,
      [final Map<String, dynamic>? arguments,
      final int? externalHandle]) async {
    final message = AblyMessage(
      message: arguments ?? {},
      handle: externalHandle ?? await handle,
    );
    return _platform.invokePlatformMethod<T>(method, message);
  }

  /// BEGIN LEGACY DOCSTRING
  /// invoke platform method channel with AblyMessage encapsulation
  ///
  /// this is similar to [invoke], but ensures the response is not null
  /// END LEGACY DOCSTRING
  Future<T> invokeRequest<T>(final String method,
      [final Map<String, dynamic>? arguments]) async {
    final response = await invoke<T>(method, arguments);
    if (response == null) {
      throw AblyException(
        message:
            'Platform communication error. Response cannot be null for $method',
      );
    } else {
      return response;
    }
  }

  /// BEGIN LEGACY DOCSTRING
  /// Listen for events
  /// END LEGACY DOCSTRING
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
