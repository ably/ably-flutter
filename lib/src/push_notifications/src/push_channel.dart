import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Enables devices to subscribe to push notifications for a channel.
class PushChannel extends PlatformObject {
  final String _name;

  /// @nodoc
  /// A rest client used platform side to invoke push notification methods
  final Rest? rest;

  /// @nodoc
  /// A realtime client used platform side to invoke push notification methods
  final Realtime? realtime;

  /// @nodoc
  /// Pass the channel name and an Ably realtime or rest client.
  PushChannel(this._name, {this.rest, this.realtime}) {
    final ablyClientNotPresent = rest == null && realtime == null;
    final moreThanOneAblyClientPresent = rest != null && realtime != null;
    if (ablyClientNotPresent || moreThanOneAblyClientPresent) {
      throw Exception(
          'Specify one Ably client when creating ${(Push).toString()}.');
    }
  }

  /// @nodoc
  @override
  Future<int?> createPlatformInstance() => (realtime != null)
      ? (realtime as Realtime).handle
      : (rest as Rest).handle;

  /// Subscribes the device to push notifications for the channel.
  Future<void> subscribeDevice() => invoke(
      PlatformMethod.pushSubscribeDevice, {TxTransportKeys.channelName: _name});

  /// Unsubscribes the device from receiving push notifications for the channel.
  Future<void> unsubscribeDevice() => invoke(
      PlatformMethod.pushUnsubscribeDevice,
      {TxTransportKeys.channelName: _name});

  /// Subscribes all devices associated with the current device's `clientId` to
  /// push notifications for the channel.
  Future<void> subscribeClient() => invoke(
      PlatformMethod.pushSubscribeClient, {TxTransportKeys.channelName: _name});

  /// Unsubscribes all devices associated with the current device's `clientId`
  /// from receiving push notifications for the channel.
  Future<void> unsubscribeClient() => invoke(
      PlatformMethod.pushUnsubscribeClient,
      {TxTransportKeys.channelName: _name});

  /// Retrieves all push subscriptions for the channel.
  ///
  /// Subscriptions can be filtered using a [params] object containing key-value
  /// pairs to filter subscriptions by. Can contain `clientId`, `deviceId` or a
  /// combination of both if concatFilters is set to true, and a limit on the
  /// number of subscriptions returned, up to 1,000.
  ///
  /// Returns a [PaginatedResult] object containing a list of
  /// [PushChannelSubscription] objects.
  Future<PaginatedResult<PushChannelSubscription>> listSubscriptions(
      Map<String, String> params) async {
    if (!params.containsKey('deviceId') &&
        !params.containsKey('clientId') &&
        !params.containsKey('deviceClientId') &&
        !params.containsKey('channel')) {
      // This error only happen on Androids. They are thrown here
      // for both platforms (iOS/ Android) to make the API more consistent.
      throw AblyException(
        message: "expected parameter 'deviceId', 'clientId', "
            "'deviceClientId', and/or 'channel'",
      );
    }

    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.pushListSubscriptions,
      {TxTransportKeys.params: params, TxTransportKeys.channelName: _name},
    );

    return PaginatedResult<PushChannelSubscription>.fromAblyMessage(
        AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message));
  }
}
