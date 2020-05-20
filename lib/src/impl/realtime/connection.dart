import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';

import '../platform_object.dart';
import '../../spec/spec.dart' show Connection, ConnectionState, ErrorInfo;


class ConnectionPlatformObject extends PlatformObject implements Connection {

  ConnectionPlatformObject(int ablyHandle, Ably ablyPlugin, int realtimeHandle)
      : super(ablyHandle, ablyPlugin, realtimeHandle);

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
  Stream<ConnectionStateChange> on([ConnectionEvent state]) {
    Stream<ConnectionStateChange> stream = listen(PlatformMethod.onRealtimeConnectionStateChanged).transform<ConnectionStateChange>(
        StreamTransformer.fromHandlers(
            handleData: (dynamic value, EventSink<ConnectionStateChange> sink){
              sink.add(value as ConnectionStateChange);
            }
        )
    );
    if (state!=null) {
      return stream.takeWhile((ConnectionStateChange _stateChange) => _stateChange.event==state);
    }
    return stream;
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