import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../../realtime/realtime.dart';
import '../../rest/rest.dart';
import '../platform.dart';

/// The native code implementation of [Push].
class PushNative extends PlatformObject implements Push {
  /// A rest client used platform side to invoke push notification methods
  final RestInterface? rest;

  /// A realtime client used platform side to invoke push notification methods
  final RealtimeInterface? realtime;

  /// Pass an Ably realtime or rest client.
  PushNative({this.rest, this.realtime}) : super() {
    final ablyClientNotPresent = rest == null && realtime == null;
    final moreThanOneAblyClientPresent = rest != null && realtime != null;
    if (ablyClientNotPresent || moreThanOneAblyClientPresent) {
      throw Exception(
          'Specify one Ably client when creating ${(PushNative).toString()}.');
    }
  }

  @override
  Future<void> activate() => invoke(PlatformMethod.pushActivate);

  @override
  Future<bool> requestNotificationPermission(
          {bool provisionalPermissionRequest = false}) async =>
      invokeRequest<bool>(PlatformMethod.pushRequestNotificationPermission, {
        TxPushRequestNotificationPermission.provisionalPermissionRequest:
            provisionalPermissionRequest
      });

  @override
  Future<void> deactivate() => invoke(PlatformMethod.pushDeactivate);

  // TODO Consider implementing the Push Admin API (it is designed for servers)
  // @override
  // PushAdmin? admin;

  @override
  Future<int?> createPlatformInstance() => (realtime != null)
      ? (realtime as Realtime).handle
      : (rest as Rest).handle;
}
