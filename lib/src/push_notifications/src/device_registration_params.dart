import 'package:ably_flutter/ably_flutter.dart';

/// Contains properties used to filter [PushDeviceRegistrations] devices.
abstract class DeviceRegistrationParams {
  /// The ID of the client.
  String? clientId;

  /// The unique ID of the device.
  String? deviceId;

  /// Limit on the number of devices returned, up to 1,000.
  int? limit;

  /// The current state of the push registration.
  DevicePushState? state;
}
