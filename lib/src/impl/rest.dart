import 'dart:async';
import 'package:flutter/services.dart';
import '../../ably.dart';
import '../spec/spec.dart' as spec;
import 'platform_object.dart';



class RestPlatformObject extends PlatformObject implements spec.Rest {

  RestPlatformObject(int ablyHandle, MethodChannel methodChannel, int handle)
      : super(ablyHandle, methodChannel, handle);

  @override
  // TODO: implement channels
  Channels<spec.Channel> get channels => null;

  @override
  Auth auth;

  @override
  ClientOptions options;

  @override
  set channels(Channels<spec.Channel> _channels) {
    // TODO: implement channels
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
  Push push;
}