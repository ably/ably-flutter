import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// To indicate Push State of a device in [DeviceDetails] via [DevicePushState]
/// while registering
/// END LEGACY DOCSTRING

/// BEGIN EDITED DOCSTRING
/// The current state of the push registration in [DevicePushDetails]
/// END EDITED DOCSTRING
enum DevicePushState {
  /// BEGIN LEGACY DOCSTRING
  /// indicates active push state of the device
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED DOCSTRING
  /// Indicates that push state of the device is `active`
  /// END EDITED DOCSTRING
  active,

  /// BEGIN LEGACY DOCSTRING
  /// indicates that push state is failing
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED DOCSTRING
  /// Indicates that push state of the device is `failing`
  /// END EDITED DOCSTRING
  failing,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device push state failed
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED DOCSTRING
  /// Indicates that push state of the device is `failed`
  /// END EDITED DOCSTRING
  failed,
}
