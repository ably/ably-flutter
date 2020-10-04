import 'dart:async';
import 'dart:collection';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../message.dart';
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
    final handle = await invokeRaw<int>(
        PlatformMethod.createRestWithOptions, AblyMessage(options));
    _restInstances[handle] = this;
    return handle;
  }

  void authUpdateComplete() {
    for(final channel in channels.all){
      channel.authUpdateComplete();
    }
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
      Object body,
      Map<String, String> headers}) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedResult<Stats>> stats([Map<String, dynamic> params]) {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> time() {
    throw UnimplementedError();
  }

  @override
  Push push;

  @override
  RestPlatformChannels channels;
}
