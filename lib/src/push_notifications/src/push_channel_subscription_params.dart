import '../push_notifications.dart';

/// Params to filter push channel subscriptions.
///
/// See [PushChannelSubscriptions.list], [PushChannelSubscriptions.removeWhere]
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1c1
abstract class PushChannelSubscriptionParams {
  /// filter by channel
  String? channel;

  /// filter by clientId
  String? clientId;

  /// filter by deviceId
  String? deviceId;

  /// limit results for each page
  int? limit;
}