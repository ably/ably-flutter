import 'package:ably_flutter/ably_flutter.dart';

/// Enables device push channel subscriptions.
abstract class PushChannelSubscriptions {
  /// Retrieves all push channel subscriptions matching the filter [params]
  /// provided. Returns a [PaginatedResult] object, containing an array of
  /// [PushChannelSubscription] objects.
  Future<PaginatedResult<PushChannelSubscription>> list(
    PushChannelSubscriptionParams params,
  );

  /// Retrieves all channels with at least one device subscribed to push
  /// notifications using a [params] object.
  ///
  /// Returns a [PaginatedResult] object, containing an array of channel names.
  Future<PaginatedResult<String>> listChannels(
    PushChannelsParams params,
  );

  /// Subscribes a device, or a group of devices sharing the same `clientId` to
  /// push notifications on a channel, using the [subscription] object.
  ///
  /// Returns a [PushChannelSubscription] object describing the new or updated
  /// subscriptions.
  Future<PushChannelSubscription> save(PushChannelSubscription subscription);

  /// Unsubscribes a device, or a group of devices sharing the same `clientId`
  /// from receiving push notifications on a channel, using the [subscription]
  /// object.
  Future<void> remove(PushChannelSubscription subscription);

  /// Unsubscribes all devices from receiving push notifications on a channel
  /// that match the filter [params] object provided.
  Future<void> removeWhere(PushChannelSubscriptionParams params);
}
