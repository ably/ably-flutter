import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/realtime/realtime.dart';

import '../../spec/spec.dart' show Connection, ConnectionState, ErrorInfo;
import '../platform_object.dart';


class ConnectionPlatformObject extends PlatformObject implements Connection {

  Realtime realtimePlatformObject;

  ConnectionPlatformObject(this.realtimePlatformObject) {
    this.handle;  //proactively acquiring handle
    this.state = ConnectionState.initialized;
    this.on().listen((ConnectionStateChange event) {
      this.state = event.current;
    });
  }

  @override
  Future<int> createPlatformInstance() async => await realtimePlatformObject.handle;

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
  Stream<ConnectionStateChange> on([ConnectionEvent connectionEvent]) {
    return listen(PlatformMethod.onRealtimeConnectionStateChanged)
      .map((connectionEvent) => connectionEvent as ConnectionStateChange)
      .where((connectionStateChange) =>
        connectionEvent==null || connectionStateChange.event==connectionEvent);
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  void connect() {
    // TODO: implement connect
  }

  @override
  Future<int> ping() {
    // TODO: implement ping
    return null;
  }

}
