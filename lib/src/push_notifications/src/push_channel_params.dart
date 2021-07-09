import '../push_notifications.dart';

/// params to filter channels on a [PushChannelSubscriptions]
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1c2
abstract class PushChannelsParams {
  /// limit results for each page
  int? limit;
}
