import 'dart:async';

import '../../../ably_flutter.dart';
import '../../spec/spec.dart'
    show ConnectionInterface, ConnectionState, ErrorInfo;
import '../platform_object.dart';
import 'realtime.dart';

/// connects to Ably service
class Connection extends PlatformObject implements ConnectionInterface {
  /// Realtime client instance
  final Realtime realtime;

  ConnectionState _state;

  /// instantiates a connection with [realtime] client instance
  ///
  /// sets default [state] to [ConnectionState.initialized] and starts listening
  /// for updates to the connection [state].
  Connection(this.realtime) : super() {
    _state = ConnectionState.initialized;
    on().listen((event) {
      if (event.reason?.code == ErrorCodes.authCallbackFailure) {
        realtime.awaitAuthUpdateAndReconnect();
      }
      _state = event.current;
    });
  }

  @override
  Future<int> createPlatformInstance() async => realtime.handle;

  @override
  ErrorInfo errorReason;

  @override
  String id;

  @override
  String key;

  @override
  String recoveryKey;

  @override
  int serial;

  @override
  ConnectionState get state => _state;

  @override
  Stream<ConnectionStateChange> on([ConnectionEvent connectionEvent]) =>
      listen<ConnectionStateChange>(
        PlatformMethod.onRealtimeConnectionStateChanged,
      ).where((connectionStateChange) =>
          connectionEvent == null ||
          connectionStateChange.event == connectionEvent);

  @override
  Future<void> close() => realtime.close();

  @override
  Future<void> connect() => realtime.connect();

  @override
  Future<int> ping() {
    throw UnimplementedError();
  }
}
