import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// To indicate the operating system -or- platform of the client using SDK
/// in [DeviceDetails] while registering
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Describes the device receiving push notifications.
/// END EDITED CANONICAL DOCSTRING
enum DevicePlatform {
  /// BEGIN LEGACY DOCSTRING
  /// indicates an android device
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The device platform is Android.
  /// END EDITED CANONICAL DOCSTRING
  android,

  /// BEGIN LEGACY DOCSTRING
  /// indicates an iOS device
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The device platform is iOS.
  /// END EDITED CANONICAL DOCSTRING
  ios,

  /// BEGIN LEGACY DOCSTRING
  /// indicates a browser
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The device platform is a web browser.
  /// END EDITED CANONICAL DOCSTRING
  browser,
}
