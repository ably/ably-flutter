import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/impl/realtime/channels.dart';
import 'package:pedantic/pedantic.dart';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'connection.dart';

Map<int, Realtime> _realtimeInstances = {};
Map<int, Realtime> _realtimeInstancesUnmodifiableView;

Map<int, Realtime> get realtimeInstances =>
    _realtimeInstancesUnmodifiableView ??=
        UnmodifiableMapView(_realtimeInstances);

class Realtime extends PlatformObject
    implements spec.RealtimeInterface<RealtimePlatformChannels> {
  Realtime({ClientOptions options, final String key})
      : assert(options != null || key != null),
        options = options ?? ClientOptions.fromKey(key),
        super() {
    connection = ConnectionPlatformObject(this);
    channels = RealtimePlatformChannels(this);
  }

  @override
  Future<int> createPlatformInstance() async {
    var handle = await invokeRaw<int>(
        PlatformMethod.createRealtimeWithOptions, AblyMessage(options));
    _realtimeInstances[handle] = this;
    return handle;
  }

  // The _connection instance keeps a reference to this platform object.
  // Ideally connection would be final, but that would need 'late final' which is coming.
  // https://stackoverflow.com/questions/59449666/initialize-a-final-variable-with-this-in-dart#comment105082936_59450231
  @override
  Connection connection;

  @override
  Auth auth;

  @override
  String clientId;

  @override
  ClientOptions options;

  @override
  Push push;

  @override
  RealtimePlatformChannels channels;

  @override
  Future<void> close() async => await invoke(PlatformMethod.closeRealtime);

  final _connectQueue = Queue<Completer<void>>();
  Completer<void> _authCallbackCompleter;

  @override
  Future<void> connect() async {
    final queueItem = Completer<void>();
    _connectQueue.add(queueItem);
    unawaited(_connect());
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
      await invoke(PlatformMethod.connectRealtime);

      _connectQueue.remove(item);

      // The Completer could have timed out in the meantime and completing a
      // completed Completer would cause an exception, so we check first.
      if (!item.isCompleted) {
        item.complete();
      }
    }
    _connecting = false;
  }

  void awaitAuthUpdateAndReconnect() async {
    if (_authCallbackCompleter != null) {
      return;
    }
    _authCallbackCompleter = Completer<void>();
    try {
      await _authCallbackCompleter.future.timeout(
          Timeouts.retryOperationOnAuthFailure,
          onTimeout: () => _connectQueue.where((e) => !e.isCompleted).forEach(
              (e) => e.completeError(TimeoutException(
                  'Timed out', Timeouts.retryOperationOnAuthFailure))));
    } finally {
      _authCallbackCompleter = null;
    }
    await connect();
  }

  void authUpdateComplete() {
    _authCallbackCompleter?.complete();
    channels.all.forEach((c) => c.authUpdateComplete());
  }

  @override
  Future<HttpPaginatedResponse> request(
      {String method,
      String path,
      Map<String, dynamic> params,
      body,
      Map<String, String> headers}) {
    // TODO: implement request
    return null;
  }

  @override
  Future<PaginatedResult<Stats>> stats([Map<String, dynamic> params]) {
    // TODO: implement stats
    return null;
  }

  @override
  Future<DateTime> time() {
    // TODO: implement time
    return null;
  }
}
