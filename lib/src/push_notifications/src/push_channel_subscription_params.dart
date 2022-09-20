import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// Params to filter push channel subscriptions.
///
/// See [PushChannelSubscriptions.list], [PushChannelSubscriptions.removeWhere]
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1c1
/// END LEGACY DOCSTRING
abstract class PushChannelSubscriptionParams {
  /// BEGIN LEGACY DOCSTRING
  /// filter by channel
  /// END LEGACY DOCSTRING
  String? channel;

  /// BEGIN LEGACY DOCSTRING
  /// filter by clientId
  /// END LEGACY DOCSTRING
  String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// filter by deviceId
  /// END LEGACY DOCSTRING
  String? deviceId;

  /// BEGIN LEGACY DOCSTRING
  /// limit results for each page
  /// END LEGACY DOCSTRING
  int? limit;
}
