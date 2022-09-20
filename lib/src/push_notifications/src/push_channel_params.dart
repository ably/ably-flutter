import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// params to filter channels on a [PushChannelSubscriptions]
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1c2
/// END LEGACY DOCSTRING
abstract class PushChannelsParams {
  /// BEGIN LEGACY DOCSTRING
  /// limit results for each page
  /// END LEGACY DOCSTRING
  int? limit;
}
