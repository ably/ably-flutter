import 'package:flutter/foundation.dart';

import '../auth.dart';
import '../common.dart';
import '../message.dart';
import '../push/push.dart';
import 'options.dart';


abstract class Crypto {
  String generateRandomKey();
}

///io.ably.lib.rest.AblyBase
abstract class AblyBase {

  AblyBase({
    ClientOptions options,
    final String key
  }):assert(options!=null || key!=null){
    this.options = (options==null)?ClientOptions.fromKey(key):options;
  }

  ClientOptions options;
  static Crypto crypto;
  static MessageStatic message;
  static PresenceMessageStatic presenceMessage;
  Auth auth;
  Push push;
  Future<PaginatedResultInterface<Stats>> stats([Map<String, dynamic> params]);
  Future<HttpPaginatedResponse> request({
    @required String method,
    @required String path,
    Map<String, dynamic> params,
    dynamic body,
    Map<String, String> headers
  });
  Future<DateTime> time();
}
