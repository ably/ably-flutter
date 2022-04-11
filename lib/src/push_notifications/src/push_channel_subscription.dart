import 'package:meta/meta.dart';

/// Details of a push subscription to a channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCS1
@immutable
class PushChannelSubscription {
  /// the channel name associated with this subscription
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS4
  final String channel;

  /// populated for subscriptions made for a specific device registration
  /// (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS2
  final String? deviceId;

  /// populated for subscriptions made for a specific clientId (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS3
  final String? clientId;

  /// Initializes an instance without any defaults
  const PushChannelSubscription({
    required this.channel,
    this.clientId,
    this.deviceId,
  });
}
