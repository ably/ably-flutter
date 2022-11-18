import 'package:ably_flutter/ably_flutter.dart';

/// Contains properties used to filter [RestPresence] members.
class RestPresenceParams {
  /// An upper limit on the number of messages returned.
  ///
  /// The default is 100, and the maximum is 1000.
  int limit;

  /// Filters the list of returned presence members by a specific client using
  /// its ID.
  String? clientId;

  /// Filters the list of returned presence members by a specific connection
  /// using its ID.
  String? connectionId;

  /// @nodoc
  /// initializes with default [limit] set to 100
  RestPresenceParams({
    this.clientId,
    this.connectionId,
    this.limit = 100,
  });
}
