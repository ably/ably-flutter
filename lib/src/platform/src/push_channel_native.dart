import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// The native code implementation of [PushChannel].
class PushChannelNative extends PlatformObject implements PushChannel {
  final String _name;

  /// A rest client used platform side to invoke push notification methods
  final RestInterface? rest;

  /// A realtime client used platform side to invoke push notification methods
  final RealtimeInterface? realtime;

  /// Pass the channel name and an Ably realtime or rest client.
  PushChannelNative(this._name, {this.rest, this.realtime}) {
    final ablyClientNotPresent = rest == null && realtime == null;
    final moreThanOneAblyClientPresent = rest != null && realtime != null;
    if (ablyClientNotPresent || moreThanOneAblyClientPresent) {
      throw Exception(
          'Specify one Ably client when creating ${(PushNative).toString()}.');
    }
  }

  @override
  Future<int?> createPlatformInstance() => (realtime != null)
      ? (realtime as Realtime).handle
      : (rest as Rest).handle;

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
      // This error only happen on Androids. They are thrown here
      // for both platforms (iOS/ Android) to make the API more consistent.
      throw AblyException(
          "expected parameter 'deviceId', 'clientId', 'deviceClientId', and/or 'channel'");
    }

    final message = await invokeRequest<AblyMessage>(
      PlatformMethod.pushListSubscriptions,
      {TxTransportKeys.params: params, TxTransportKeys.channelName: _name},
    );

    return PaginatedResult<PushChannelSubscription>.fromAblyMessage(
        AblyMessage.castFrom<dynamic, PaginatedResult>(message));
  }
}
