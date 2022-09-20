import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// To indicate the type of device in [DeviceDetails] while registering
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCD4
/// END LEGACY DOCSTRING
enum FormFactor {
  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a mobile phone
  /// END LEGACY DOCSTRING
  phone,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a tablet
  /// END LEGACY DOCSTRING
  tablet,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a desktop
  /// END LEGACY DOCSTRING
  desktop,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a television
  /// END LEGACY DOCSTRING
  tv,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a smart watch
  /// END LEGACY DOCSTRING
  watch,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is an automobile
  /// END LEGACY DOCSTRING
  car,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is an embedded system / iOT device
  /// END LEGACY DOCSTRING
  embedded,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device belong to categories other than mentioned above
  /// END LEGACY DOCSTRING
  other,
}
