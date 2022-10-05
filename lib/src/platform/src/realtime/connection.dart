import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// connects to Ably service using a [web-socket](https://www.ably.com/topic/websockets) connection
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTN1
class Connection extends PlatformObject {
  /// Realtime client instance
  final Realtime realtime;

  ConnectionState _state;

  ErrorInfo? _errorReason;

  /// instantiates a connection with [realtime] client instance
  ///
  /// sets default [state] to [ConnectionState.initialized] and starts listening
  /// for updates to the connection [state].
  Connection(this.realtime)
      : _state = ConnectionState.initialized,
        super() {
    on().listen((event) {
      _state = event.current;
      _errorReason = event.reason;
    });
  }

  @override
  Future<int> createPlatformInstance() async => realtime.handle;

  /// Error information associated with connection failure
  ///
  /// See:
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN14
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN15
  ErrorInfo? get errorReason => _errorReason;

  /// A public identifier for this connection, used to identify
  /// this member in presence events and message ids.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN8
  String? id;

  /// A unique private connection key provided by Ably that is used to reconnect
  /// and retain connection state following an unexpected disconnection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN9
  String? key;

  /// https://docs.ably.com/client-lib-development-guide/features/#RTN16g
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN16h
  Future<String?> getRecoveryKey() async =>
      invoke(PlatformMethod.getRealtimeConnectionRecoveryKey);

  /// current state of this connection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#connection-states-operations
  ConnectionState get state => _state;

  /// stream of connection events with specified [ConnectionEvent] type
  Stream<ConnectionStateChange> on([ConnectionEvent? connectionEvent]) =>
      listen<ConnectionStateChange>(
        PlatformMethod.onRealtimeConnectionStateChanged,
      ).where((connectionStateChange) =>
          connectionEvent == null ||
          connectionStateChange.event == connectionEvent);

  /// closes the connection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN12
  Future<void> close() => realtime.close();

  /// Explicitly connects to Ably service if not already connected
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN11
  Future<void> connect() => realtime.connect();

  /// ping's ably server
  ///
  /// Will send a ProtocolMessage with action HEARTBEAT the Ably service when
  /// connected and expects a HEARTBEAT message in response
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN13
  Future<int> ping() {
    throw UnimplementedError();
  }
}
