import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRING
/// Enables device push channel subscriptions.
/// END EDITED CANONICAL DOCSTRING
abstract class PushChannelSubscriptions {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves all push channel subscriptions matching the filter [params]
  /// provided. Returns a [PaginatedResult] object, containing an array of
  /// [PushChannelSubscription] objects.
  /// END EDITED CANONICAL DOCSTRING
  Future<PaginatedResult<PushChannelSubscription>> list(
    PushChannelSubscriptionParams params,
  );

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves all channels with at least one device subscribed to push
  /// notifications using a [params] object. Returns a [PaginatedResult] object,
  /// containing an array of channel names.
  /// END EDITED CANONICAL DOCSTRING
  Future<PaginatedResult<String>> listChannels(
    PushChannelsParams params,
  );

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Subscribes a device, or a group of devices sharing the same `clientId` to
  /// push notifications on a channel, using the [subscription] object. Returns
  /// a [PushChannelSubscription] object describing the new or updated
  /// subscriptions.
  /// END EDITED CANONICAL DOCSTRING
  Future<PushChannelSubscription> save(PushChannelSubscription subscription);

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Unsubscribes a device, or a group of devices sharing the same `clientId`
  /// from receiving push notifications on a channel, using the [subscription]
  /// object.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> remove(PushChannelSubscription subscription);

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Unsubscribes all devices from receiving push notifications on a channel
  /// that match the filter [params] object provided.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> removeWhere(PushChannelSubscriptionParams params);
}
