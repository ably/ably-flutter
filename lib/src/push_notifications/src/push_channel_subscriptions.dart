import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Manage push notification channel subscriptions for devices or clients
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Enables device push channel subscriptions.
/// END CANONICAL DOCSTRING
abstract class PushChannelSubscriptions {
  /// BEGIN LEGACY DOCSTRING
  /// List channel subscriptions filtered by optional params.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c1
  /// END LEGACY DOCSTRING
  Future<PaginatedResult<PushChannelSubscription>> list(
    PushChannelSubscriptionParams params,
  );

  /// BEGIN LEGACY DOCSTRING
  /// List channels with at least one subscribed device.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c2
  /// END LEGACY DOCSTRING
  Future<PaginatedResult<String>> listChannels(
    PushChannelsParams params,
  );

  /// BEGIN LEGACY DOCSTRING
  /// Save push channel subscription for a device or client ID.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c3
  /// END LEGACY DOCSTRING
  Future<PushChannelSubscription> save(PushChannelSubscription subscription);

  /// BEGIN LEGACY DOCSTRING
  /// Remove a push channel subscription.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c4
  /// END LEGACY DOCSTRING
  Future<void> remove(PushChannelSubscription subscription);

  /// BEGIN LEGACY DOCSTRING
  /// Remove all matching push channel subscriptions.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RSH1c5
  /// END LEGACY DOCSTRING
  Future<void> removeWhere(PushChannelSubscriptionParams params);
}
