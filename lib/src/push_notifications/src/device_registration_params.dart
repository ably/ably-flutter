import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Params to filter push device registrations.
///
/// see: [PushDeviceRegistrations.list], [PushDeviceRegistrations.removeWhere]
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1b2
/// END LEGACY DOCSTRING
abstract class DeviceRegistrationParams {
  /// BEGIN LEGACY DOCSTRING
  /// filter by client id
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The ID of the client.
  /// END CANONICAL DOCSTRING
  String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// filter by device id
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The unique ID of the device.
  /// END EDITED CANONICAL DOCSTRING
  String? deviceId;

  /// BEGIN LEGACY DOCSTRING
  /// limit results for each page
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Limit on the number of devices returned, up to 1,000.
  /// END EDITED CANONICAL DOCSTRING
  int? limit;

  /// BEGIN LEGACY DOCSTRING
  /// filter by device state
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The current state of the push registration.
  /// END EDITED CANONICAL DOCSTRING
  DevicePushState? state;
}
