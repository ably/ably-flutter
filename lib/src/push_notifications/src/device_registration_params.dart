import '../push_notifications.dart';
import 'device_push_state.dart';

/// Params to filter push device registrations.
///
/// see: [PushDeviceRegistrations.list], [PushDeviceRegistrations.removeWhere]
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1b2
abstract class DeviceRegistrationParams {
  /// filter by client id
  String? clientId;

  /// filter by device id
  String? deviceId;

  /// limit results for each page
  int? limit;

  /// filter by device state
  DevicePushState? state;
}