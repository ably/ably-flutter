import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRINGS
/// Contains properties used to filter [PushDeviceRegistrations] devices.
/// END EDITED CANONICAL DOCSTRINGS
abstract class DeviceRegistrationParams {
  /// BEGIN CANONICAL DOCSTRING
  /// The ID of the client.
  /// END CANONICAL DOCSTRING
  String? clientId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The unique ID of the device.
  /// END EDITED CANONICAL DOCSTRING
  String? deviceId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Limit on the number of devices returned, up to 1,000.
  /// END EDITED CANONICAL DOCSTRING
  int? limit;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The current state of the push registration.
  /// END EDITED CANONICAL DOCSTRING
  DevicePushState? state;
}
