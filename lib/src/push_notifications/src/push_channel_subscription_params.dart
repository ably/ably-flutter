import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRINGS
/// Contains properties used to filter [PushChannel] subscriptions.
/// END EDITED CANONICAL DOCSTRINGS
abstract class PushChannelSubscriptionParams {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The channel name.
  /// END EDITED CANONICAL DOCSTRING
  String? channel;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The ID of the client.
  /// END EDITED CANONICAL DOCSTRING
  String? clientId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// The unique ID of the device.
  /// END EDITED CANONICAL DOCSTRING
  String? deviceId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A limit on the number of devices returned, up to 1,000.
  /// END EDITED CANONICAL DOCSTRING
  int? limit;
}
