import 'package:meta/meta.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Contains the subscriptions of a device, or a group of devices sharing the
/// same `clientId`, has to a channel in order to receive push notifications.
/// END EDITED CANONICAL DOCSTRING
@immutable
class PushChannelSubscription {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel the push notification subscription is for.
  /// END EDITED CANONICAL DOCSTRING
  final String channel;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The unique ID of the device.
  /// END EDITED CANONICAL DOCSTRING
  final String? deviceId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The ID of the client the device, or devices are associated to.
  /// END EDITED CANONICAL DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// Initializes an instance without any defaults
  /// END LEGACY DOCSTRING
  const PushChannelSubscription({
    required this.channel,
    this.clientId,
    this.deviceId,
  });
}
