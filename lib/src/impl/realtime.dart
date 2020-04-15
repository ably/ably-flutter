import 'dart:async';
import 'connection.dart';
import 'package:flutter/services.dart';
import '../../ably.dart';
import '../spec/spec.dart' as spec;
import 'platform_object.dart';



class RealtimePlatformObject extends PlatformObject implements spec.Realtime {
  // The _connection instance keeps a reference to this platform object.
  // Ideally _connection would be final, but that would need 'late final' which is coming.
  // https://stackoverflow.com/questions/59449666/initialize-a-final-variable-with-this-in-dart#comment105082936_59450231
  ConnectionIndirectPlatformObject _connection;

  RealtimePlatformObject(int ablyHandle, MethodChannel methodChannel, int handle)
      : super(ablyHandle, methodChannel, handle) {
    _connection = ConnectionIndirectPlatformObject(this);
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  Future<void> connect() async {
    await invoke(PlatformMethod.connectRealtime);
  }

  @override
  Connection get connection => _connection;

  @override
  Auth auth;

  @override
  String clientId;

  @override
  ClientOptions options;

  @override
  Push push;

  @override
  void set connection(Connection _connection) {
    // TODO: implement connection
  }

  @override
  Future<HttpPaginatedResponse> request({String method, String path, Map<String, dynamic> params, body, Map<String, String> headers}) {
    // TODO: implement request
    return null;
  }

  @override
  Future<PaginatedResult<Stats>> stats([Map<String, dynamic> params]) {
    // TODO: implement stats
    return null;
  }

  @override
  Future<int> time() {
    // TODO: implement time
    return null;
  }

  @override
  RealtimeChannels channels;
}