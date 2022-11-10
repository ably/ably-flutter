import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Enables the management of device registrations and push notification
/// subscriptions. Also enables the publishing of push notifications to devices.
/// END EDITED CANONICAL DOCSTRING
abstract class PushAdmin {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [PushDeviceRegistrations] object.
  /// END EDITED CANONICAL DOCSTRING
  PushDeviceRegistrations? deviceRegistrations;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A [PushChannelSubscriptions] object.
  /// END EDITED CANONICAL DOCSTRING
  PushChannelSubscriptions? channelSubscriptions;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Sends a push notification, provided in the [payload] map, directly to a
  /// device, or a group of devices sharing the same `clientId`.
  ///
  /// Set the [recipient] map containing the recipient details using
  /// `clientId`, `deviceId` or the underlying notifications service.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> publish(
    Map<String, dynamic> recipient,
    Map<String, dynamic> payload,
  );
}
