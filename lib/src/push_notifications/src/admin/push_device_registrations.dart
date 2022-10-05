import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Manage device registrations for push notifications
///
/// https://ably.com/documentation/general/push/admin#device-registrations
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Enables the management of push notification registrations with Ably.
/// END EDITED CANONICAL DOCSTRING
abstract class PushDeviceRegistrations {
  /// BEGIN LEGACY DOCSTRING
  /// Get registered device by device ID.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b1
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves the [DeviceDetails] of a device registered
  /// to receive push notifications using the `id` property of a
  /// [DeviceDetails] object, or by directly using the unique [deviceId].
  /// END EDITED CANONICAL DOCSTRING
  Future<DeviceDetails> get({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// BEGIN LEGACY DOCSTRING
  /// List registered devices filtered by optional params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b2
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves all devices matching the filter [params] provided.
  /// Returns a [PaginatedResult] object, containing an array of [DeviceDetails]
  /// objects.
  /// END EDITED CANONICAL DOCSTRING
  Future<PaginatedResult<DeviceDetails>> list(
    DeviceRegistrationParams params,
  );

  /// BEGIN LEGACY DOCSTRING
  /// Save and register device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b3
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Registers or updates a [deviceDetails] object with Ably. Returns the new,
  /// or updated [DeviceDetails] object.
  /// END EDITED CANONICAL DOCSTRING
  Future<DeviceDetails> save(DeviceDetails deviceDetails);

  /// BEGIN LEGACY DOCSTRING
  /// Remove device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b4
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Removes a device registered to receive push notifications from Ably using
  /// the id property of a [deviceDetails] object, or by directly using the
  /// unique [deviceId].
  /// END EDITED CANONICAL DOCSTRING
  Future<void> remove({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// BEGIN LEGACY DOCSTRING
  /// Remove device matching where params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b5
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Removes all devices registered to receive push notifications from Ably
  /// matching the filter [params] provided.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> removeWhere(DeviceRegistrationParams params);
}
