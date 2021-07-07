import '../push_notifications.dart';

/// To indicate the type of device in [DeviceDetails] while registering
///
/// https://docs.ably.com/client-lib-development-guide/features/#PCD4
enum FormFactor {
  /// indicates the device is a mobile phone
  phone,

  /// indicates the device is a tablet
  tablet,

  /// indicates the device is a desktop
  desktop,

  /// indicates the device is a television
  tv,

  /// indicates the device is a smart watch
  watch,

  /// indicates the device is an automobile
  car,

  /// indicates the device is an embedded system / iOT device
  embedded,

  /// indicates the device belong to categories other than mentioned above
  other,
}
