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
  Future<DeviceDetails> get({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// BEGIN LEGACY DOCSTRING
  /// List registered devices filtered by optional params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b2
  /// END LEGACY DOCSTRING
  Future<PaginatedResult<DeviceDetails>> list(
    DeviceRegistrationParams params,
  );

  /// BEGIN LEGACY DOCSTRING
  /// Save and register device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b3
  /// END LEGACY DOCSTRING
  Future<DeviceDetails> save(DeviceDetails deviceDetails);

  /// BEGIN LEGACY DOCSTRING
  /// Remove device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b4
  /// END LEGACY DOCSTRING
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
