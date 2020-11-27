import 'dart:async';

import '../../../ably_flutter.dart';
import '../../spec/spec.dart'
    show ConnectionInterface, ConnectionState, ErrorInfo;
import '../platform_object.dart';
import 'realtime.dart';

class Connection extends PlatformObject implements ConnectionInterface {
  Realtime realtimePlatformObject;

  Connection(this.realtimePlatformObject) : super() {
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
  Future<void> close() => realtimePlatformObject.close();

  @override
  Future<void> connect() => realtimePlatformObject.connect();

  @override
  Future<int> ping() {
    throw UnimplementedError();
  }
}
