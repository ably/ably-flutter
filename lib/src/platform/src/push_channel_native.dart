import '../../common/common.dart';
import '../../generated/platform_constants.dart';
import '../../push_notifications/push_notifications.dart';
import '../platform.dart';

class PushChannelNative extends PlatformObject implements PushChannel {
  String _name;
  Future<int?> _handle;

  PushChannelNative(this._name, this._handle) : super();

  @override
  Future<int?> createPlatformInstance() => _handle;

  @override
  Future<void> subscribeClient() => invoke(
      PlatformMethod.pushSubscribeClient, {TxTransportKeys.channelName: _name});

  /// Subscribe device to the channel’s push notifications.
  @override
  Future<void> subscribeDevice() => invoke(
      PlatformMethod.pushSubscribeDevice, {TxTransportKeys.channelName: _name});

  @override
  Future<void> unsubscribeClient() => invoke(
      PlatformMethod.pushUnsubscribeClient,
      {TxTransportKeys.channelName: _name});

  /// Unsubscribe device from the channel’s push notifications.
  @override
  Future<void> unsubscribeDevice() => invoke(
      PlatformMethod.pushUnsubscribeDevice,
      {TxTransportKeys.channelName: _name});

  @override
  Future<PaginatedResultInterface<PushChannelSubscription>> listSubscriptions(
          [Map<String, dynamic>? params]) =>
      invokeRequest<PaginatedResultInterface<PushChannelSubscription>>(
          PlatformMethod.pushListSubscriptions);
}
