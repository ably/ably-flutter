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
  String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// filter by device id
  /// END LEGACY DOCSTRING
  String? deviceId;

  /// BEGIN LEGACY DOCSTRING
  /// limit results for each page
  /// END LEGACY DOCSTRING
  int? limit;

  /// BEGIN LEGACY DOCSTRING
  /// filter by device state
  /// END LEGACY DOCSTRING
  DevicePushState? state;
}
