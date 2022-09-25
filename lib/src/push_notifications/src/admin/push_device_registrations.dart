import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Manage device registrations for push notifications
///
/// https://ably.com/documentation/general/push/admin#device-registrations
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Enables the management of push notification registrations with Ably.
/// END CANONICAL DOCSTRING
abstract class PushDeviceRegistrations {
  /// BEGIN LEGACY DOCSTRING
  /// Get registered device by device ID.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b1
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves the [DeviceDetails]{@link DeviceDetails} of a device registered
  /// to receive push notifications using the id property of a
  /// [DeviceDetails]{@link DeviceDetails} object.
  ///
  /// [DeviceDetails] - The [DeviceDetails]{@link DeviceDetails} object
  /// containing the id property of the device.
  ///
  /// [DeviceDetails] - A [DeviceDetails]{@link DeviceDetails} object.
  /// END CANONICAL DOCSTRING
  Future<DeviceDetails> get({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// BEGIN LEGACY DOCSTRING
  /// List registered devices filtered by optional params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves all devices matching the filter params provided. Returns a
  /// [PaginatedResult]{@link PaginatedResult} object, containing an array of
  /// [DeviceDetails]{@link DeviceDetails} objects.
  ///
  /// [params] - An object containing key-value pairs to filter devices by.
  /// Can contain clientId, deviceId and a limit on the number of devices
  /// returned, up to 1,000.
  ///
  /// [PaginatedResult<DeviceDetails>] - A
  /// [PaginatedResult]{@link PaginatedResult} object containing an array of
  /// [DeviceDetails]{@link DeviceDetails} objects.
  /// END CANONICAL DOCSTRING
  Future<PaginatedResult<DeviceDetails>> list(
    DeviceRegistrationParams params,
  );

  /// BEGIN LEGACY DOCSTRING
  /// Save and register device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Registers or updates a [DeviceDetails]{@link DeviceDetails} object with
  /// Ably. Returns the new, or updated [DeviceDetails]{@link DeviceDetails}
  /// object.
  ///
  /// [DeviceDetails] - The [DeviceDetails]{@link DeviceDetails} object to
  /// create or update.
  ///
  /// [DeviceDetails] - A [DeviceDetails]{@link DeviceDetails} object.
  /// END CANONICAL DOCSTRING
  Future<DeviceDetails> save(DeviceDetails deviceDetails);

  /// BEGIN LEGACY DOCSTRING
  /// Remove device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b4
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Removes a device registered to receive push notifications from Ably using
  /// the id property of a [DeviceDetails]{@link DeviceDetails} object.
  ///
  /// [DeviceDetails] - The [DeviceDetails]{@link DeviceDetails} object
  /// containing the id property of the device.
  /// END CANONICAL DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Removes a device registered to receive push notifications from Ably using
  /// its deviceId.
  /// 
  /// [deviceId] - The unique ID of the device.
  /// END CANONICAL DOCSTRING
  Future<void> remove({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// BEGIN LEGACY DOCSTRING
  /// Remove device matching where params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b5
  /// END LEGACY DOCSTRING
  Future<void> removeWhere(DeviceRegistrationParams params);
}
