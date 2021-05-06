import '../common.dart';

/// Manage push notification channel subscriptions for devices or clients
abstract class PushChannelSubscriptions {
  /// List channel subscriptions filtered by optional params.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1c1
  Future<PaginatedResultInterface<PushChannelSubscription>> list(
    PushChannelSubscriptionParams params,
  );

  /// List channels with at least one subscribed device.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1c2
  Future<PaginatedResultInterface<String>> listChannels(
    PushChannelsParams params,
  );

  /// Save push channel subscription for a device or client ID.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1c3
  Future<PushChannelSubscription> save(PushChannelSubscription subscription);

  /// Remove a push channel subscription.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1c4
  Future<void> remove(PushChannelSubscription subscription);

  /// Remove all matching push channel subscriptions.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1c5
  Future<void> removeWhere(PushChannelSubscriptionParams params);
}

/// Manage device registrations for push notifications
abstract class PushDeviceRegistrations {
  /// Get registered device by device ID.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1b1
  Future<DeviceDetails> get({
    DeviceDetails deviceDetails,
    String deviceId,
  });

  /// List registered devices filtered by optional params.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1b2
  Future<PaginatedResultInterface<DeviceDetails>> list(
    DeviceRegistrationParams params,
  );

  /// Save and register device.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1b3
  Future<DeviceDetails> save(DeviceDetails deviceDetails);

  /// Remove device.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1b4
  Future<void> remove({
    DeviceDetails deviceDetails,
    String deviceId,
  });

  /// Remove device matching where params.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1b5
  Future<void> removeWhere(DeviceRegistrationParams params);
}

/// Class providing push notification administrative functionality
/// for registering devices and attaching to channels etc.
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSH1
abstract class PushAdmin {
  /// Manage device registrations.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1b
  PushDeviceRegistrations deviceRegistrations;

  /// Manage channel subscriptions for devices or clients.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1c
  PushChannelSubscriptions channelSubscriptions;

  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1a
  Future<void> publish(Map<String, dynamic> recipient, Map payload);
}

/// Class providing push notification functionality
///
/// https://docs.ably.io/client-lib-development-guide/features/#RSH1
abstract class Push {
  /// Admin features for push notifications like managing devices
  /// and channel subscriptions.
  ///
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH1
  PushAdmin admin;

  /// Activate this device for push notifications by registering
  /// with the push transport such as GCM/APNS.
  ///
  /// returns DeviceDetails
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH2a
  Future<DeviceDetails> activate();

  /// Deactivate this device for push notifications by removing
  /// the registration with the push transport such as GCM/APNS.
  ///
  /// returns deviceId
  /// https://docs.ably.io/client-lib-development-guide/features/#RSH2b
  Future<String> deactivate();
}
