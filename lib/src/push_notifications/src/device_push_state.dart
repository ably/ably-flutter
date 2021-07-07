/// To indicate Push State of a device in [DeviceDetails] via [DevicePushState]
/// while registering
enum DevicePushState {
  /// indicates active push state of the device
  active,

  /// indicates that push state is failing
  failing,

  /// indicates the device push state failed
  failed,
}