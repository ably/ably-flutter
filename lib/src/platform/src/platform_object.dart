import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// @nodoc
/// A representation of a Platform side instance (Android, iOS).
abstract class PlatformObject {
  Future<int>? _handle;
  final Platform _platform = Platform();
  int? _handleValue; // Only for logging. Otherwise use _handle instead.

  /// @nodoc
  /// Immediately instantiates an object on platform side by calling
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

  /// @nodoc
  /// Creates an instance of this object on platform side.
  Future<int?> createPlatformInstance();

  /// @nodoc
  /// Returns [_handle] which will be same as handle on platform side.
  ///
  /// If [_handle] is empty, it creates platform instance, acquires handle,
  /// updates [_handle] and returns it.
  Future<int> get handle async => _handle ??= _acquireHandle();

  Future<int> _acquireHandle() =>
      createPlatformInstance().then((value) => (_handleValue = value)!);

  /// @nodoc
  /// Invoke platform method channel without current handle.
  ///
  /// This method should be protected since it's only used to cover edge
  /// case for creating rest and realtime instances.
  @protected
  Future<T?> invokeWithoutHandle<T>(final String method,
      [final Map<String, dynamic>? argument]) async {
    final message = AblyMessage(
      message: argument ?? {},
    );
    return _platform.invokePlatformMethod<T>(method, message);
  }

  /// @nodoc
  /// Invoke platform method channel with provided handle, or
  /// current handle if [externalHandle] is not provided.
  Future<T?> invoke<T>(final String method,
      [final Map<String, dynamic>? arguments,
      final int? externalHandle]) async {
    final message = AblyMessage(
      message: arguments ?? {},
      handle: externalHandle ?? await handle,
    );
    return _platform.invokePlatformMethod<T>(method, message);
  }

  /// @nodoc
  /// Invoke platform method channel with AblyMessage encapsulation.
  ///
  /// This is similar to [invoke], but ensures the response is not null.
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

  /// @nodoc
  /// Listen for events.
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
