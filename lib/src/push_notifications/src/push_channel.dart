import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// Channel to receive push notifications on
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH7
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Enables devices to subscribe to push notifications for a channel.
/// END CANONICAL DOCSTRING
class PushChannel extends PlatformObject {
  final String _name;

  /// BEGIN LEGACY DOCSTRING
  /// A rest client used platform side to invoke push notification methods
  /// END LEGACY DOCSTRING
  final Rest? rest;

  /// BEGIN LEGACY DOCSTRING
  /// A realtime client used platform side to invoke push notification methods
  /// END LEGACY DOCSTRING
  final Realtime? realtime;

  /// BEGIN LEGACY DOCSTRING
  /// Pass the channel name and an Ably realtime or rest client.
  /// END LEGACY DOCSTRING
  PushChannel(this._name, {this.rest, this.realtime}) {
    final ablyClientNotPresent = rest == null && realtime == null;
    final moreThanOneAblyClientPresent = rest != null && realtime != null;
    if (ablyClientNotPresent || moreThanOneAblyClientPresent) {
      throw Exception(
          'Specify one Ably client when creating ${(Push).toString()}.');
    }
  }

  @override
  Future<int?> createPlatformInstance() => (realtime != null)
      ? (realtime as Realtime).handle
      : (rest as Rest).handle;

  /// BEGIN LEGACY DOCSTRING
  /// Subscribes device to push notifications on channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7a
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Subscribes the device to push notifications for the channel.
  /// END CANONICAL DOCSTRING
  Future<void> subscribeDevice() => invoke(
      PlatformMethod.pushSubscribeDevice, {TxTransportKeys.channelName: _name});

  /// BEGIN LEGACY DOCSTRING
  /// un-subscribes device from push notifications
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7c
  /// END LEGACY DOCSTRING
  Future<void> unsubscribeDevice() => invoke(
      PlatformMethod.pushUnsubscribeDevice,
      {TxTransportKeys.channelName: _name});

  /// BEGIN LEGACY DOCSTRING
  /// Subscribes client to push notifications on the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7b
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Subscribes all devices associated with the current device's clientId to
  /// push notifications for the channel.
  /// END CANONICAL DOCSTRING
  Future<void> subscribeClient() => invoke(
      PlatformMethod.pushSubscribeClient, {TxTransportKeys.channelName: _name});

  /// BEGIN LEGACY DOCSTRING
  /// un-subscribes client from push notifications
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7d
  /// END LEGACY DOCSTRING
  Future<void> unsubscribeClient() => invoke(
      PlatformMethod.pushUnsubscribeClient,
      {TxTransportKeys.channelName: _name});

  /// BEGIN LEGACY DOCSTRING
  /// Lists subscriptions
  ///
  /// as [PushChannelSubscription] objects encapsulated in a paginated result.
  /// Optional filters can be passed as a [params] map. These filters include
  /// [channel, deviceId, clientId and limit](https://ably.com/docs/rest-api/#list-channel-subscriptions).
  ///
  /// Requires Push Admin capability
  ///
  /// To listSubscriptions on Android, params must include a `deviceId` key.
  /// This is because the package plugin uses ably-java.
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7e
  /// END LEGACY DOCSTRING
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
