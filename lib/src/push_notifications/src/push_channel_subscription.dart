/// Details of a push subscription to a channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCS1
abstract class PushChannelSubscription {
  /// the channel name associated with this subscription
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS4
  String? channel;

  /// populated for subscriptions made for a specific device registration
  /// (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS2
  String? deviceId;

  /// populated for subscriptions made for a specific clientId (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS3
  String? clientId;
}
