import 'package:flutter/foundation.dart';

import '../common.dart';
import '../connection.dart';
import '../rest/ably_base.dart';
import '../rest/options.dart';
import 'channels.dart';


//REST BASE
abstract class RealtimeBase extends AblyBase {
  RealtimeBase.fromOptions(ClientOptions options): super.fromOptions(options);
  RealtimeBase.fromKey(String key): super.fromKey(key);
  String clientId;
  void close();
  void connect();
}

class Realtime extends RealtimeBase {
  Realtime.fromOptions(ClientOptions options): super.fromOptions(options){
    channels = RealtimeChannels(this);
  }
  Realtime.fromKey(String key): super.fromKey(key){
    channels = RealtimeChannels(this);
  }
  Connection connection;
  RealtimeChannels channels;
  close(){
    //TODO implement
  }
  connect(){
    //TODO implement
  }
  Future<PaginatedResult<Stats>> stats([Map<String, dynamic> params]){
    //TODO implement
    return null;
  }
  Future<HttpPaginatedResponse> request({
    @required String method,
    @required String path,
    Map<String, dynamic> params,
    dynamic body,
    Map<String, String> headers
  }){
    //TODO implement
    return null;
  }

  Future<int> time(){
    //TODO implement
    return null;
  }

}