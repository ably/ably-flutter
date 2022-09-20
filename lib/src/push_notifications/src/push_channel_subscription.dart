import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Details of a push subscription to a channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCS1
/// END LEGACY DOCSTRING
@immutable
class PushChannelSubscription {
  /// BEGIN LEGACY DOCSTRING
  /// the channel name associated with this subscription
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS4
  /// END LEGACY DOCSTRING
  final String channel;

  /// BEGIN LEGACY DOCSTRING
  /// populated for subscriptions made for a specific device registration
  /// (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS2
  /// END LEGACY DOCSTRING
  final String? deviceId;

  /// BEGIN LEGACY DOCSTRING
  /// populated for subscriptions made for a specific clientId (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS3
  /// END LEGACY DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// Initializes an instance without any defaults
  /// END LEGACY DOCSTRING
  const PushChannelSubscription({
    required this.channel,
    this.clientId,
    this.deviceId,
  });
}
