import 'dart:async';

import '../../../ably.dart';
import '../../spec/spec.dart' show Connection, ConnectionState, ErrorInfo;
import '../platform_object.dart';
import 'realtime.dart';

class ConnectionPlatformObject extends PlatformObject implements Connection {
  Realtime realtimePlatformObject;

  ConnectionPlatformObject(this.realtimePlatformObject) : super() {
    state = ConnectionState.initialized;
    on().listen((event) {
      if (event.reason?.code == ErrorCodes.authCallbackFailure) {
        realtimePlatformObject.awaitAuthUpdateAndReconnect();
      }
      state = event.current;
    });
  }

  @override
  Future<int> createPlatformInstance() async => realtimePlatformObject.handle;

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
  ConnectionState state;

  @override
  Stream<ConnectionStateChange> on([ConnectionEvent connectionEvent]) =>
      listen(PlatformMethod.onRealtimeConnectionStateChanged)
          .map((connectionEvent) => connectionEvent as ConnectionStateChange)
          .where((connectionStateChange) =>
              connectionEvent == null ||
              connectionStateChange.event == connectionEvent);

  @override
  void close() {
    throw UnimplementedError();
  }

  @override
  void connect() {
    throw UnimplementedError();
  }

  @override
  Future<int> ping() {
    throw UnimplementedError();
  }
}
