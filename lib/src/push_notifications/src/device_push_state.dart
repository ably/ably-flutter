import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// To indicate Push State of a device in [DeviceDetails] via [DevicePushState]
/// while registering
/// END LEGACY DOCSTRING
enum DevicePushState {
  /// BEGIN LEGACY DOCSTRING
  /// indicates active push state of the device
  /// END LEGACY DOCSTRING
  active,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that push state is failing
  /// END LEGACY DOCSTRING
  failing,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device push state failed
  /// END LEGACY DOCSTRING
  failed,
}
