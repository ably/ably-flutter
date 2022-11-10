import 'package:ably_flutter/ably_flutter.dart';

/// BEGIN EDITED CANONICAL DOCSTRINGS
/// Contains properties used to filter [RestPresence] members.
/// END EDITED CANONICAL DOCSTRINGS
class RestPresenceParams {
  /// BEGIN EDITED CANONICAL DOCSTRING
  /// An upper limit on the number of messages returned. The default is 100, and
  /// the maximum is 1000.
  /// END EDITED CANONICAL DOCSTRING
  int limit;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Filters the list of returned presence members by a specific client using
  /// its ID.
  /// END EDITED CANONICAL DOCSTRING
  String? clientId;

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Filters the list of returned presence members by a specific connection
  /// using its ID.
  /// END EDITED CANONICAL DOCSTRING
  String? connectionId;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// initializes with default [limit] set to 100
  /// END LEGACY DOCSTRING
  RestPresenceParams({
    this.clientId,
    this.connectionId,
    this.limit = 100,
  });
}
