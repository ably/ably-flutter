import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// connects to Ably service using a [web-socket](https://www.ably.com/topic/websockets) connection
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTN1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Enables the management of a connection to Ably.
/// END CANONICAL DOCSTRING
class Connection extends PlatformObject {
  /// Realtime client instance
  final Realtime realtime;

  ConnectionState _state;

  ErrorInfo? _errorReason;

  /// BEGIN LEGACY DOCSTRING
  /// instantiates a connection with [realtime] client instance
  ///
  /// sets default [state] to [ConnectionState.initialized] and starts listening
  /// for updates to the connection [state].
  /// END LEGACY DOCSTRING
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

  /// BEGIN LEGACY DOCSTRING
  /// Error information associated with connection failure
  ///
  /// See:
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN14
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN15
  /// END LEGACY DOCSTRING
  ErrorInfo? get errorReason => _errorReason;

  /// BEGIN LEGACY DOCSTRING
  /// A public identifier for this connection, used to identify
  /// this member in presence events and message ids.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN8
  /// END LEGACY DOCSTRING
  String? id;

  /// BEGIN LEGACY DOCSTRING
  /// A unique private connection key provided by Ably that is used to reconnect
  /// and retain connection state following an unexpected disconnection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN9
  /// END LEGACY DOCSTRING
  String? key;

  /// BEGIN LEGACY DOCSTRING
  /// RTN16b) Connection#recoveryKey is an attribute composed of the
  /// connection key and latest serial received on the connection
  /// END LEGACY DOCSTRING
  String? recoveryKey;

  /// BEGIN LEGACY DOCSTRING
  /// The serial number of the last message to be received on this connection.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN10
  /// END LEGACY DOCSTRING
  int? serial;

  /// BEGIN LEGACY DOCSTRING
  /// current state of this connection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#connection-states-operations
  /// END LEGACY DOCSTRING
  ConnectionState get state => _state;

  /// BEGIN LEGACY DOCSTRING
  /// stream of connection events with specified [ConnectionEvent] type
  /// END LEGACY DOCSTRING
  Stream<ConnectionStateChange> on([ConnectionEvent? connectionEvent]) =>
      listen<ConnectionStateChange>(
        PlatformMethod.onRealtimeConnectionStateChanged,
      ).where((connectionStateChange) =>
          connectionEvent == null ||
          connectionStateChange.event == connectionEvent);

  /// BEGIN LEGACY DOCSTRING
  /// closes the connection
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN12
  /// END LEGACY DOCSTRING
  Future<void> close() => realtime.close();

  /// BEGIN LEGACY DOCSTRING
  /// Explicitly connects to Ably service if not already connected
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN11
  /// END LEGACY DOCSTRING
  Future<void> connect() => realtime.connect();

  /// BEGIN LEGACY DOCSTRING
  /// ping's ably server
  ///
  /// Will send a ProtocolMessage with action HEARTBEAT the Ably service when
  /// connected and expects a HEARTBEAT message in response
  /// https://docs.ably.com/client-lib-development-guide/features/#RTN13
  /// END LEGACY DOCSTRING
  Future<int> ping() {
    throw UnimplementedError();
  }
}
