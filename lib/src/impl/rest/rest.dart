import 'dart:async';

import 'package:ably_flutter_plugin/src/impl/message.dart';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'channels.dart';


class Rest extends PlatformObject implements spec.RestInterface<RestPlatformChannels> {

  Rest({
    ClientOptions options,
    final String key
  }) :
      assert(options!=null || key!=null),
      this.options = (options==null)?ClientOptions.fromKey(key):options,
      super()
  {
    this.channels = RestPlatformChannels(this);
  }

  Future<int> createPlatformInstance() async => await invokeRaw<int>(
    PlatformMethod.createRestWithOptions,
    AblyMessage(options)
  );

  @override
  Auth auth;

  @override
  ClientOptions options;

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

  @override
  Push push;

  @override
  RestPlatformChannels channels;
}
