import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// To indicate the type of device in [DeviceDetails] while registering
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCD4
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Describes the type of device receiving a push notification.
/// END CANONICAL DOCSTRING
enum FormFactor {
  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a mobile phone
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is a phone.
  /// END CANONICAL DOCSTRING
  phone,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a tablet
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is tablet.
  /// END CANONICAL DOCSTRING
  tablet,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a desktop
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is a desktop.
  /// END CANONICAL DOCSTRING
  desktop,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a television
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is a TV.
  /// END CANONICAL DOCSTRING
  tv,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is a smart watch
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is a watch.
  /// END CANONICAL DOCSTRING
  watch,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is an automobile
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is a car.
  /// END CANONICAL DOCSTRING
  car,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device is an embedded system / iOT device
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is embedded.
  /// END CANONICAL DOCSTRING
  embedded,

  /// BEGIN LEGACY DOCSTRING
  /// indicates the device belong to categories other than mentioned above
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// The device is other.
  /// END CANONICAL DOCSTRING
  other,
}
