import 'dart:async';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'connection.dart';


class RealtimePlatformObject extends PlatformObject implements spec.Realtime {

  RealtimePlatformObject(int ablyHandle, Ably ablyPlugin, int handle, {
    ClientOptions options,
    final String key
  })
      :assert(options!=null || key!=null),
        connection = ConnectionPlatformObject(ablyHandle, ablyPlugin, handle),
        super(ablyHandle, ablyPlugin, handle) {
    this.options = (options==null)?ClientOptions.fromKey(key):options;
  }

  @override
  final Connection connection;

  @override
  Auth auth;

  @override
  String clientId;

  @override
  ClientOptions options;

  @override
  Push push;

  @override
  RealtimeChannels channels;

  @override
  Future<void> close() async => await invoke(PlatformMethod.closeRealtime);

  @override
  Future<void> connect() async => await invoke(PlatformMethod.connectRealtime);

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
  Future<DateTime> time() {
    // TODO: implement time
    return null;
  }
}
