import 'dart:async';

import 'package:flutter/services.dart';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'channels.dart';


class RestPlatformObject extends PlatformObject implements spec.Rest<RestPlatformChannels> {

  RestPlatformObject(int ablyHandle, MethodChannel methodChannel, int handle, {
    ClientOptions options,
    final String key
  })
      :assert(options!=null || key!=null),
        super(ablyHandle, methodChannel, handle){
    this.options = (options==null)?ClientOptions.fromKey(key):options;
    this.channels = RestPlatformChannels(ablyHandle, methodChannel, handle, this);
  }

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