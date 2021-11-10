import 'package:ably_flutter/ably_flutter.dart';

/// Channel to receive push notifications on
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH7
abstract class PushChannel {
  /// Subscribes device to push notifications on channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7a
  Future<void> subscribeDevice();

  /// Subscribes client to push notifications on the channel
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7b
  Future<void> subscribeClient();

  /// un-subscribes device from push notifications
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7c
  Future<void> unsubscribeDevice();

  /// un-subscribes client from push notifications
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7d
  Future<void> unsubscribeClient();

  /// Lists subscriptions
  ///
  /// as [PushChannelSubscription] objects encapsulated in a paginated result.
  /// Optional filters can be passed as a [params] map. These filters include
  /// [channel, deviceId, clientId and limit](https://docs.ably.io/rest-api/#list-channel-subscriptions).
  ///
  /// Requires Push Admin capability
  ///
  /// To listSubscriptions on Android, params must include a `deviceId` key.
  /// This is because the package plugin uses ably-java.
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH7e
  Future<PaginatedResult<PushChannelSubscription>> listSubscriptions(
      Map<String, String> params);
}
