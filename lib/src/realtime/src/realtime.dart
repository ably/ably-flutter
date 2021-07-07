import '../../authentication/authentication.dart';
import '../../common/common.dart';
import '../realtime.dart';

/// an abstract class for Ably's Realtime client
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTC1
abstract class RealtimeInterface<C extends RealtimeChannelsInterface>
    extends AblyBase {
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC1
  RealtimeInterface({
    ClientOptions? options,
    final String? key,
  }) : super(options: options, key: key);

  /// closes the [connection]
  void close();

  /// connects to [connection]
  void connect();

  /// Provides access to the underlying Connection object
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC2
  ConnectionInterface get connection;

  /// collection of [RealtimeChannelInterface] objects
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTC3
  C get channels;
}
