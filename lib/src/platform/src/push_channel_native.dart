import '../../common/common.dart';
import '../../push_notifications/push_notifications.dart';
import '../platform.dart';

class PushChannelNative extends PlatformObject implements PushChannel {
  /// Subscribe device to the channel’s push notifications.
  void subscribe() {}

  /// Unsubscribe device from the channel’s push notifications.
  void unsubscribe() {}

  @override
  Future<int?> createPlatformInstance() {
    // TODO: implement createPlatformInstance
    throw UnimplementedError();
  }

  @override
  Future<void> subscribeClient() {
    // TODO: implement subscribeClient
    throw UnimplementedError();
  }

  @override
  Future<void> subscribeDevice() {
    // TODO: implement subscribeDevice
    throw UnimplementedError();
  }

  @override
  Future<void> unsubscribeClient() {
    // TODO: implement unsubscribeClient
    throw UnimplementedError();
  }

  @override
  Future<void> unsubscribeDevice() {
    // TODO: implement unsubscribeDevice
    throw UnimplementedError();
  }

  @override
  Future<PaginatedResultInterface<PushChannelSubscription>> listSubscriptions(
      [Map<String, dynamic>? params]) {
    // TODO: implement listSubscriptions
    throw UnimplementedError();
  }
}
