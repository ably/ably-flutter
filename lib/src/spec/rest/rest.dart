import '../rest/ably_base.dart';
import '../rest/options.dart';
import 'ably_base.dart';
import 'channels.dart';
import 'options.dart';

abstract class RestInterface<C extends RestChannels> extends AblyBase {
  C channels;

  RestInterface({
    ClientOptions options,
    final String key,
  }) : super(
          options: options,
          key: key,
        );

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
