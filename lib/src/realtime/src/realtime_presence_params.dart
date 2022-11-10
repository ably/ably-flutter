import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Params used as a filter for querying presence on a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTP11c
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRINGS
/// Contains properties used to filter [RealtimePresence] members.
/// END EDITED CANONICAL DOCSTRINGS
@immutable
class RealtimePresenceParams {
  /// BEGIN LEGACY DOCSTRING
  /// When true, [RealtimePresence.get] will wait until SYNC is complete
  /// before returning a list of members
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c1
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Whether to wait for a full presence set synchronization between Ably
  /// and the clients on the channel to complete before returning the results.
  /// Synchronization begins as soon as the channel is [ChannelState.attached].
  /// When set to true the results will be returned as soon as the sync is
  /// complete. When set to false the current list of members will be returned
  /// without the sync completing. The default is true.
  /// END CANONICAL DOCSTRING
  final bool waitForSync;

  /// BEGIN LEGACY DOCSTRING
  /// filters members by the provided clientId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c2
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Filters the array of returned presence members by a specific client using
  /// its ID.
  /// END CANONICAL DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// filters members by the provided connectionId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c3
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Filters the array of returned presence members by a specific connection
  /// using its ID.
  /// END CANONICAL DOCSTRING
  final String? connectionId;

  /// BEGIN LEGACY DOCSTRING
  /// @nodoc
  /// initializes with [waitForSync] set to true by default
  /// END LEGACY DOCSTRING
  const RealtimePresenceParams({
    this.clientId,
    this.connectionId,
    this.waitForSync = true,
  });
}
