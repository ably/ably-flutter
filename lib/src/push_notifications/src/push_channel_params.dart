import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRINGS
/// Contains properties used to filter [PushChannelSubscriptions] channels.
/// END EDITED CANONICAL DOCSTRINGS
abstract class PushChannelsParams {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// A limit on the number of channels returned, up to 1,000.
  /// END EDITED CANONICAL DOCSTRING
  int? limit;
}
