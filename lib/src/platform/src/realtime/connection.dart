import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Enables the management of a connection to Ably.
class Connection extends PlatformObject {
  /// @nodoc
  /// Realtime client instance
  final Realtime realtime;

  ConnectionState _state;

  ErrorInfo? _errorReason;

  /// @nodoc
  /// Instantiates a connection with [realtime] client instance.
  ///
  /// Sets default [state] to [ConnectionState.initialized] and starts listening
  /// for updates to the connection [state].
  Connection(this.realtime)
      : _state = ConnectionState.initialized,
        super() {
    on().listen((event) {
      _state = event.current;
      _errorReason = event.reason;
    });
  }

  /// @nodoc
  @override
  Future<int> createPlatformInstance() async => realtime.handle;

  /// An [ErrorInfo] object describing the last error received if a connection
  /// failure occurs.
  ErrorInfo? get errorReason => _errorReason;

  /// A unique public identifier for this connection, used to identify this
  /// member.
  String? id;

  /// A unique private connection key used to recover or resume a connection,
  /// assigned by Ably.
  ///
  /// When recovering a connection explicitly, the `recoveryKey` is used in the
  /// recover client options as it contains both the key and the last message
  /// serial. This private connection key can also be used by other REST clients
  /// to publish on behalf of this client. See the
  /// [publishing over REST on behalf of a realtime client docs](https://ably.com/docs/rest/channels#publish-on-behalf)
  /// for more info.
  String? key;

  /// The recovery key string can be used by another client to recover this
  /// connection's state in the recover client options property.
  ///
  /// See [connection state recover options](https://ably.com/docs/realtime/connection#connection-state-recover-options)
  /// for more information.
  String? recoveryKey;

  /// The serial number of the last message to be received on this connection,
  /// used automatically by the library when recovering or resuming a
  /// connection.
  ///
  /// When recovering a connection explicitly, the `recoveryKey` is
  /// used in the recover client options as it contains both the key and the
  /// last message serial.
  int? serial;

  /// The current [ConnectionState] of the connection.
  ConnectionState get state => _state;

  /// Stream of connection events with specified [ConnectionEvent] type.
  Stream<ConnectionStateChange> on([ConnectionEvent? connectionEvent]) =>
      listen<ConnectionStateChange>(
        PlatformMethod.onRealtimeConnectionStateChanged,
      ).where((connectionStateChange) =>
          connectionEvent == null ||
          connectionStateChange.event == connectionEvent);

  /// Causes the connection to close, entering the [ConnectionState.closing]
  /// state.
  ///
  /// Once closed, the library does not attempt to re-establish the connection
  /// without an explicit call to [Connection.connect].
  Future<void> close() => realtime.close();

  /// Explicitly calling `connect()` is unnecessary unless the `autoConnect`
  /// attribute of the [ClientOptions] object is false.
  ///
  /// Unless already connected or connecting, this method causes the connection
  /// to open, entering the [ConnectionState.connecting] state.
  Future<void> connect() => realtime.connect();

  /// When connected, sends a heartbeat ping to the Ably server and executes the
  /// callback with any error and the response time in milliseconds when a
  /// heartbeat ping request is echoed from the server.
  ///
  /// This can be useful for measuring true round-trip latency to the connected
  /// Ably server. Returns the response time in miliseconds as [int].
  Future<int> ping() {
    throw UnimplementedError();
  }
}
