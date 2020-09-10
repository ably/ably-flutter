import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';
import 'package:ably_flutter_plugin/src/impl/realtime/channels.dart';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'connection.dart';

Map<int, Realtime> realtimeInstances = {};

class Realtime extends PlatformObject
    implements spec.RealtimeInterface<RealtimePlatformChannels> {
  Realtime({ClientOptions options, final String key})
      : assert(options != null || key != null),
        options = (options == null) ? ClientOptions.fromKey(key) : options,
        super() {
    connection = ConnectionPlatformObject(this);
    channels = RealtimePlatformChannels(this);
  }

  @override
  Future<int> createPlatformInstance() async {
    var handle = await invokeRaw<int>(
        PlatformMethod.createRealtimeWithOptions, AblyMessage(options));
    realtimeInstances[handle] = this;
    return handle;
  }

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
  RealtimePlatformChannels channels;

  @override
  Future<void> close() async => await invoke(PlatformMethod.closeRealtime);

  bool authCallbackInProgress = false;

  @override
  Future<void> connect() async {
    var hasAuthCallback = options.authCallback != null;
    while (hasAuthCallback && authCallbackInProgress) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    await invoke(PlatformMethod.connectRealtime);
  }

  void authUpdateComplete() {
    authCallbackInProgress = false;
  }

  @override
  Future<HttpPaginatedResponse> request(
      {String method,
      String path,
      Map<String, dynamic> params,
      body,
      Map<String, String> headers}) {
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
