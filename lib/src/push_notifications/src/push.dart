import '../push_notifications.dart';
import 'admin/push_admin.dart';

/// Class providing push notification functionality
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1
abstract class Push {
  /// Admin features for push notifications like managing devices
  /// and channel subscriptions.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1
  // TODO Consider implementing the push admin API
  // PushAdmin? admin;

  /// Activate this device for push notifications by registering
  /// with the push transport such as GCM/APNS.
  ///
  /// returns DeviceDetails
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH2a
  Future<DeviceDetails> activate();

  /// Deactivate this device for push notifications by removing
  /// the registration with the push transport such as GCM/APNS.
  ///
  /// returns deviceId
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH2b
  Future<String> deactivate();
}
