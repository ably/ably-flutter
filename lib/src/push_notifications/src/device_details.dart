import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Details of a registered device.
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCD1
@immutable
class DeviceDetails {
  /// The id of the device registration.
  ///
  /// Generated locally if not available
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD2
  final String? id;

  /// populated for device registrations associated with a clientId (optional)
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD3
  final String? clientId;

  /// The device platform.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD6
  final DevicePlatform platform;

  /// the device form factor.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD4
  final FormFactor formFactor;

  /// a map of string key/value pairs containing any other registered
  /// metadata associated with the device registration
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD5
  final Map<String, String> metadata;

  /// Details of the push registration for this device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#PCD7
  final DevicePushDetails push;

  /// Initializes an instance without any defaults
  const DeviceDetails({
    required this.formFactor,
    required this.metadata,
    required this.platform,
    required this.push,
    this.clientId,
    this.id,
  });
}
