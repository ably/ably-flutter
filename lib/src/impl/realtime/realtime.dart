import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/impl/realtime/channels.dart';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'connection.dart';


class Realtime extends PlatformObject implements spec.RealtimeInterface {

  Realtime({
    ClientOptions options,
    final String key
  }) :
      assert(options!=null || key!=null),
      this.options = (options==null)?ClientOptions.fromKey(key):options,
      super()
  {
    connection = ConnectionPlatformObject(this);
    channels = RealtimePlatformChannels(this);
  }

  @override
  Future<int> createPlatformInstance() async => await invokeRaw<int>(
    PlatformMethod.createRealtimeWithOptions,
    AblyMessage(options)
  );

  // The _connection instance keeps a reference to this platform object.
  // Ideally connection would be final, but that would need 'late final' which is coming.
  // https://stackoverflow.com/questions/59449666/initialize-a-final-variable-with-this-in-dart#comment105082936_59450231
  @override
  Connection connection;

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
