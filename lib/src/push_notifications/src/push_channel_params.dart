import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN LEGACY DOCSTRING
/// params to filter channels on a [PushChannelSubscriptions]
///
/// https://docs.ably.com/client-lib-development-guide/features/#RSH1c2
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRINGS
/// Contains properties used to filter [PushChannelSubscriptions] channels.
/// END EDITED CANONICAL DOCSTRINGS
abstract class PushChannelsParams {
  /// BEGIN LEGACY DOCSTRING
  /// limit results for each page
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A limit on the number of channels returned, up to 1,000.
  /// END EDITED CANONICAL DOCSTRING
  int? limit;
}
