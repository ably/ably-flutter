import 'dart:async';
import 'dart:collection';

import 'package:ably_flutter_plugin/src/impl/message.dart';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'channels.dart';

Map<int, Rest> _restInstances = {};
Map<int, Rest> _restInstancesUnmodifiableView;

Map<int, Rest> get restInstances =>
    _restInstancesUnmodifiableView ??= UnmodifiableMapView(_restInstances);

class Rest extends PlatformObject
    implements spec.RestInterface<RestPlatformChannels> {
  Rest({ClientOptions options, final String key})
      : assert(options != null || key != null),
        options = options ?? ClientOptions.fromKey(key),
        super() {
    channels = RestPlatformChannels(this);
  }

  @override
  Future<int> createPlatformInstance() async {
    var handle = await invokeRaw<int>(
        PlatformMethod.createRestWithOptions, AblyMessage(options));
    _restInstances[handle] = this;
    return handle;
  }

  void authUpdateComplete() {
    channels.all.forEach((c) => c.authUpdateComplete());
  }

  @override
  Auth auth;

  @override
  ClientOptions options;

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

  @override
  Push push;

  @override
  RestPlatformChannels channels;
}
