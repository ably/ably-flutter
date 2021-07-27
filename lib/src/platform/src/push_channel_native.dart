import 'package:ably_flutter/ably_flutter.dart';

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

  /// Subscribe device to the channel’s push notifications.
  @override
  Future<void> subscribeDevice() => invoke(
      PlatformMethod.pushSubscribeDevice, {TxTransportKeys.channelName: _name});

  /// Unsubscribe device from the channel’s push notifications.
  @override
  Future<void> unsubscribeDevice() => invoke(
      PlatformMethod.pushUnsubscribeDevice,
      {TxTransportKeys.channelName: _name});

  @override
  Future<void> subscribeClient() => invoke(
      PlatformMethod.pushSubscribeClient, {TxTransportKeys.channelName: _name});

  @override
  Future<void> unsubscribeClient() => invoke(
      PlatformMethod.pushUnsubscribeClient,
      {TxTransportKeys.channelName: _name});

  @override
  Future<PaginatedResultInterface<PushChannelSubscription>> listSubscriptions(
      Map<String, String> params) async {
    if (!params.containsKey('deviceId') &&
        !params.containsKey('clientId') &&
        !params.containsKey('deviceClientId') &&
        !params.containsKey('channel')) {
      final errorInfo = ErrorInfo(
          code: 40000,
          href: 'https://help.ably.io/error/40000',
          message:
              "expected parameter 'deviceId', 'clientId', 'deviceClientId', and/or 'channel'");

      throw AblyException(
          '40000',
          "expected parameter 'deviceId', 'clientId', 'deviceClientId', and/or 'channel'",
          errorInfo);
    }

    final message = await invokeRequest<AblyMessage>(
      PlatformMethod.pushListSubscriptions,
      {TxTransportKeys.params: params, TxTransportKeys.channelName: _name},
    );

    return PaginatedResult<PushChannelSubscription>.fromAblyMessage(
        AblyMessage.castFrom<dynamic, PaginatedResult>(message));
  }
}
