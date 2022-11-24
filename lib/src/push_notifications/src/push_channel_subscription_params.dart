import 'package:ably_flutter/ably_flutter.dart';

/// Contains properties used to filter [PushChannel] subscriptions.
abstract class PushChannelSubscriptionParams {
  /// The channel name.
  String? channel;

  /// The ID of the client.
  String? clientId;

  /// The unique ID of the device.
  String? deviceId;

  /// A limit on the number of devices returned, up to 1,000.
  int? limit;
}
