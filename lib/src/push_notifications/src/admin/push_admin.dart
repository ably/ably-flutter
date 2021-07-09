import '../push_channel_subscriptions.dart';
import 'push_device_registrations.dart';

/// Class providing push notification administrative functionality
/// for registering devices and attaching to channels etc.
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1
abstract class PushAdmin {
  /// Manage device registrations.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b
  PushDeviceRegistrations? deviceRegistrations;

  /// Manage channel subscriptions for devices or clients.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c
  PushChannelSubscriptions? channelSubscriptions;

  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1a
  Future<void> publish(Map<String, dynamic> recipient, Map payload);
}
