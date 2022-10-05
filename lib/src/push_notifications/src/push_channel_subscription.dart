import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Details of a push subscription to a channel.
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCS1
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains the subscriptions of a device, or a group of devices sharing the
/// same `clientId`, has to a channel in order to receive push notifications.
/// END EDITED CANONICAL DOCSTRING
@immutable
class PushChannelSubscription {
  /// BEGIN LEGACY DOCSTRING
  /// the channel name associated with this subscription
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS4
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel the push notification subscription is for.
  /// END EDITED CANONICAL DOCSTRING
  final String channel;

  /// BEGIN LEGACY DOCSTRING
  /// populated for subscriptions made for a specific device registration
  /// (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS2
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The unique ID of the device.
  /// END EDITED CANONICAL DOCSTRING
  final String? deviceId;

  /// BEGIN LEGACY DOCSTRING
  /// populated for subscriptions made for a specific clientId (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCS3
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The ID of the client the device, or devices are associated to.
  /// END EDITED CANONICAL DOCSTRING
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
