import '../connection.dart';
import '../rest/ably_base.dart';
import '../rest/options.dart';
import 'channels.dart';


abstract class RealtimeInterface extends AblyBase {

  RealtimeInterface({
    ClientOptions options,
    final String key
  }): connection=null,  //To be assigned as required on implementation
      super(options: options, key: key);

  String clientId;
  void close();
  void connect();
  final Connection connection;
  RealtimeChannels channels;

}
