import '../connection.dart';
import '../rest/ably_base.dart';
import '../rest/options.dart';
import 'channels.dart';

abstract class RealtimeInterface<C extends RealtimeChannels> extends AblyBase {
  RealtimeInterface({
    ClientOptions options,
    final String key,
  }) : super(
          options: options,
          key: key,
        );

  String clientId;

  void close();

  void connect();

  Connection get connection;

  C get channels;
}
