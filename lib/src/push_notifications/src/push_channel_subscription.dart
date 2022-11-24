import 'package:meta/meta.dart';

/// Contains the subscriptions of a device, or a group of devices sharing the
/// same `clientId`, has to a channel in order to receive push notifications.
@immutable
class PushChannelSubscription {
  /// The channel the push notification subscription is for.
  final String channel;

  /// The unique ID of the device.
  final String? deviceId;

  /// The ID of the client the device, or devices are associated to.
  final String? clientId;

  /// @nodoc
  /// Initializes an instance without any defaults
  const PushChannelSubscription({
    required this.channel,
    this.clientId,
    this.deviceId,
  });
}
