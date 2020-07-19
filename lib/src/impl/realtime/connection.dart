import 'dart:async';

import 'package:ably_flutter_plugin/ably.dart';
import 'package:ably_flutter_plugin/src/impl/realtime/realtime.dart';

import '../../spec/spec.dart' show Connection, ConnectionState, ErrorInfo;
import '../platform_object.dart';


class ConnectionPlatformObject extends PlatformObject implements Connection {

  Realtime realtimePlatformObject;

  ConnectionPlatformObject(this.realtimePlatformObject);

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
    Stream<ConnectionStateChange> stream = listen(PlatformMethod.onRealtimeConnectionStateChanged).transform<ConnectionStateChange>(
        StreamTransformer.fromHandlers(
            handleData: (dynamic value, EventSink<ConnectionStateChange> sink){
              ConnectionStateChange stateChange = value as ConnectionStateChange;
              this.state = stateChange.current;
              sink.add(stateChange);
            }
        )
    );
    if (connectionEvent!=null) {
      return stream.takeWhile((ConnectionStateChange _stateChange) => _stateChange.event==connectionEvent);
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
