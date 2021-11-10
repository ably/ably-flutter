import '../../common/common.dart';
import '../realtime.dart';

/// A collection of realtime channel objects
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTS1
abstract class RealtimeChannelsInterface<T extends RealtimeChannelInterface>
    extends Channels<T> {
  /// instance of ably realtime client
  RealtimeInterface realtime;

  /// instantiates with the ably [RealtimeInterface] instance
  RealtimeChannelsInterface(this.realtime);
}
