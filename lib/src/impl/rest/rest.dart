import 'dart:async';

import 'package:flutter/services.dart';

import '../../../ably.dart';
import '../../spec/spec.dart' as spec;
import '../platform_object.dart';
import 'channels.dart';


class RestPlatformObject extends PlatformObject implements spec.Rest<RestPlatformChannels> {

  RestPlatformObject.fromOptions(int ablyHandle, MethodChannel methodChannel, int handle, this.options)
      :super(ablyHandle, methodChannel, handle){
    this.channels = RestPlatformChannels(ablyHandle, methodChannel, handle, this);
  }

  RestPlatformObject.fromKey(int ablyHandle, MethodChannel methodChannel, int handle, String key)
      :super(ablyHandle, methodChannel, handle){
    this.options = ClientOptions.fromKey(key);
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
  Future<int> time() {
    // TODO: implement time
    return null;
  }

  @override
  Push push;

  @override
  RestPlatformChannels channels;
}