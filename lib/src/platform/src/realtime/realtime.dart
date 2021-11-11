import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

Map<int?, Realtime> _realtimeInstances = {};
Map<int?, Realtime>? _realtimeInstancesUnmodifiableView;

/// Returns readonly copy of instances of all [Realtime] clients created.
Map<int?, Realtime> get realtimeInstances =>
    _realtimeInstancesUnmodifiableView ??=
        UnmodifiableMapView(_realtimeInstances);

///  Realtime client
class Realtime extends PlatformObject {
  /// instantiates with [ClientOptions] and a String [key]
  ///
  /// creates client options from key if [key] is provided
  ///
  /// raises [AssertionError] if both [options] and [key] are null
  Realtime({
    ClientOptions? options,
    final String? key,
  })  : assert(options != null || key != null),
        options = options ?? ClientOptions.fromKey(key!),
        super() {
    _connection = Connection(this);
    _channels = RealtimeChannels(this);
    push = PushNative(realtime: this);
  }

  @override
  Future<int?> createPlatformInstance() async {
    final handle = await invokeRaw<int>(
      PlatformMethod.createRealtimeWithOptions,
      AblyMessage(options),
    );
    _realtimeInstances[handle] = this;
    return handle;
  }

  // The _connection instance keeps a reference to this platform object.
  late final Connection _connection;

  /// Provides access to the underlying Connection object
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC2
  Connection get connection => _connection;

  Auth? auth;

  ClientOptions options;

  late Push push;

  late RealtimeChannels _channels;

  /// collection of [RealtimeChannelInterface] objects
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC3
  RealtimeChannels get channels => _channels;

  /// closes the [connection]
  Future<void> close() async => invoke(PlatformMethod.closeRealtime);

  final _connectQueue = Queue<Completer<void>>();
  Completer<void>? _authCallbackCompleter;

  /// connects to [connection]
  Future<void> connect() async {
    final queueItem = Completer<void>();
    _connectQueue.add(queueItem);
    unawaitedWorkaroundForDartPre214(_connect());
    return queueItem.future;
  }

  bool _connecting = false;

  Future<void> _connect() async {
    if (_connecting) {
      return;
    }
    _connecting = true;
    while (_connectQueue.isNotEmpty) {
      final item = _connectQueue.first;
      // This is the only place where failed items are removed from the queue.
      // In all other places (timeout exceptions) only the Completer is
      // completed with an error but left in the queue.  Other attempts became a
      // bit unwieldy.
      if (item.isCompleted) {
        _connectQueue.remove(item);
        continue;
      }

      try {
        await invoke(PlatformMethod.connectRealtime);
      } finally {
        _connectQueue.remove(item);
      }

      // The Completer could have timed out in the meantime and completing a
      // completed Completer would cause an exception, so we check first.
      if (!item.isCompleted) {
        item.complete();
      }
    }
    _connecting = false;
  }

  /// @internal
  /// required due to the complications involved in the way ably-java expects
  /// authCallback to be performed synchronously, while method channel call from
  /// platform side to dart side is asynchronous
  ///
  /// discussion: https://github.com/ably/ably-flutter/issues/31
  Future<void> awaitAuthUpdateAndReconnect() async {
    if (_authCallbackCompleter != null) {
      return;
    }
    _authCallbackCompleter = Completer<void>();
    try {
      await _authCallbackCompleter!.future.timeout(
          Timeouts.retryOperationOnAuthFailure,
          onTimeout: () => _connectQueue
              .where((e) => !e.isCompleted)
              .forEach((e) => e.completeError(
                    TimeoutException(
                      'Timed out',
                      Timeouts.retryOperationOnAuthFailure,
                    ),
                  )));
    } finally {
      _authCallbackCompleter = null;
    }
    await connect();
  }

  /// @internal
  /// required due to the complications involved in the way ably-java expects
  /// authCallback to be performed synchronously, while method channel call from
  /// platform side to dart side is asynchronous
  ///
  /// discussion: https://github.com/ably/ably-flutter/issues/31
  void authUpdateComplete() {
    _authCallbackCompleter?.complete();
    for (final channel in channels) {
      channel.authUpdateComplete();
    }
  }

  Future<HttpPaginatedResponse> request({
    required String method,
    required String path,
    Map<String, dynamic>? params,
    Object? body,
    Map<String, String>? headers,
  }) {
    throw UnimplementedError();
  }

  Future<PaginatedResult<Stats>> stats([Map<String, dynamic>? params]) {
    throw UnimplementedError();
  }

  Future<DateTime> time() {
    throw UnimplementedError();
  }

  Future<LocalDevice> device() async =>
      invokeRequest<LocalDevice>(PlatformMethod.pushDevice);
}
