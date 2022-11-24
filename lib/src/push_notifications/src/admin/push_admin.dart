import 'package:ably_flutter/ably_flutter.dart';

/// Enables the management of device registrations and push notification
/// subscriptions. Also enables the publishing of push notifications to devices.
abstract class PushAdmin {
  /// A [PushDeviceRegistrations] object.
  PushDeviceRegistrations? deviceRegistrations;

  /// A [PushChannelSubscriptions] object.
  PushChannelSubscriptions? channelSubscriptions;

  /// Sends a push notification, provided in the [payload] map, directly to a
  /// device, or a group of devices sharing the same `clientId`.
  ///
  /// Sets the [recipient] map containing the recipient details using
  /// `clientId`, `deviceId` or the underlying notifications service.
  Future<void> publish(
    Map<String, dynamic> recipient,
    Map<String, dynamic> payload,
  );
}
