import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// Contains properties used to filter [RealtimePresence] members.
@immutable
class RealtimePresenceParams {
  /// Whether to wait for a full presence set synchronization between Ably
  /// and the clients on the channel to complete before returning the results.
  ///
  /// Synchronization begins as soon as the channel is [ChannelState.attached].
  /// When set to true the results will be returned as soon as the sync is
  /// complete. When set to false the current list of members will be returned
  /// without the sync completing. The default is true.
  final bool waitForSync;

  /// Filters the array of returned presence members by a specific client using
  /// its ID.
  final String? clientId;

  /// Filters the array of returned presence members by a specific connection
  /// using its ID.
  final String? connectionId;

  /// @nodoc
  /// initializes with [waitForSync] set to true by default
  const RealtimePresenceParams({
    this.clientId,
    this.connectionId,
    this.waitForSync = true,
  });
}
