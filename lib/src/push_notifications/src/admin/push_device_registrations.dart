import 'package:ably_flutter/ably_flutter.dart';

/// Manage device registrations for push notifications
///
/// https://ably.com/documentation/general/push/admin#device-registrations
abstract class PushDeviceRegistrations {
  /// Get registered device by device ID.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b1
  Future<DeviceDetails> get({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// List registered devices filtered by optional params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b2
  Future<PaginatedResult<DeviceDetails>> list(
    DeviceRegistrationParams params,
  );

  /// Save and register device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b3
  Future<DeviceDetails> save(DeviceDetails deviceDetails);

  /// Remove device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b4
  Future<void> remove({
    DeviceDetails? deviceDetails,
    String? deviceId,
  });

  /// Remove device matching where params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1b5
  Future<void> removeWhere(DeviceRegistrationParams params);
}
