import '../../common.dart';

/// Manage push notification channel subscriptions for devices or clients
abstract class PushChannelSubscriptions {
  /// List channel subscriptions filtered by optional params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c1
  Future<PaginatedResultInterface<PushChannelSubscription>> list(
    PushChannelSubscriptionParams params,
  );

  /// List channels with at least one subscribed device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c2
  Future<PaginatedResultInterface<String>> listChannels(
    PushChannelsParams params,
  );

  /// Save push channel subscription for a device or client ID.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c3
  Future<PushChannelSubscription> save(PushChannelSubscription subscription);

  /// Remove a push channel subscription.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c4
  Future<void> remove(PushChannelSubscription subscription);

  /// Remove all matching push channel subscriptions.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c5
  Future<void> removeWhere(PushChannelSubscriptionParams params);
}
