import '../../common/common.dart';
import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../platform.dart';

class PushNative extends PlatformObject implements Push {
  Future<int?> _handle;

  PushNative(this._handle) : super();

  @override
  Future<void> activate() => invoke(PlatformMethod.pushActivate);

  @override
  Future<void> deactivate() => invoke(PlatformMethod.pushDeactivate);

  // TODO Consider implementing the push admin API (it is designed for servers though)
  // @override
  // PushAdmin? admin;

  @override
  Future<int?> createPlatformInstance() => _handle;
}
