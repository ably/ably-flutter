import 'package:ably_flutter/ably_flutter.dart';

/// Enables the management of push notification registrations with Ably.
abstract class PushDeviceRegistrations {
  /// Retrieves the [DeviceDetails] of a device registered
  /// to receive push notifications using the `id` property of a
  /// [DeviceDetails] object, or by directly using the unique [deviceId].
  Future<DeviceDetails> get({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// Retrieves all devices matching the filter [params] provided.
  /// Returns a [PaginatedResult] object, containing an array of [DeviceDetails]
  /// objects.
  Future<PaginatedResult<DeviceDetails>> list(
    DeviceRegistrationParams params,
  );

  /// Registers or updates a [deviceDetails] object with Ably. Returns the new,
  /// or updated [DeviceDetails] object.
  Future<DeviceDetails> save(DeviceDetails deviceDetails);

  /// Removes a device registered to receive push notifications from Ably using
  /// the id property of a [deviceDetails] object, or by directly using the
  /// unique [deviceId].
  Future<void> remove({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// Removes all devices registered to receive push notifications from Ably
  /// matching the filter [params] provided.
  Future<void> removeWhere(DeviceRegistrationParams params);
}
