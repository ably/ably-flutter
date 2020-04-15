//import 'package:flutter/foundation.dart';

import '../auth.dart';
//import '../common.dart';
import '../push/push.dart';
import '../rest/ably_base.dart';
import '../rest/options.dart';
import 'ably_base.dart';
import 'channels.dart';
import 'options.dart';


abstract class Rest<C extends RestChannels> extends AblyBase {

  Auth auth;
  Push push;
  C channels;

  Rest.fromOptions(ClientOptions options): super.fromOptions(options);
  /*{
    channels = RestChannels(this);
  }*/
  Rest.fromKey(String key): super.fromKey(key);
  /*{
    channels = RestChannels(this);
  }*/

  /*Future<PaginatedResult<Stats>> stats([Map<String, dynamic> params]){
    //TO-DO implement
    return null;
  }
  Future<HttpPaginatedResponse> request({
    @required String method,
    @required String path,
    Map<String, dynamic> params,
    dynamic body,
    Map<String, String> headers
  }){
    //TO-DO implement
    return null;
  }

  Future<int> time(){
    //TO-DO implement
    return null;
  }*/

}
