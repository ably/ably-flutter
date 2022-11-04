import 'package:ably_flutter/ably_flutter.dart';
import 'package:meta/meta.dart';

/// BEGIN LEGACY DOCSTRING
/// Params used as a filter for querying presence on a channel
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTP11c
/// END LEGACY DOCSTRING
@immutable
class RealtimePresenceParams {
  /// BEGIN LEGACY DOCSTRING
  /// When true, [RealtimePresence.get] will wait until SYNC is complete
  /// before returning a list of members
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c1
  /// END LEGACY DOCSTRING
  final bool waitForSync;

  /// BEGIN LEGACY DOCSTRING
  /// filters members by the provided clientId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c2
  /// END LEGACY DOCSTRING
  final String? clientId;

  /// BEGIN LEGACY DOCSTRING
  /// filters members by the provided connectionId
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11c3
  /// END LEGACY DOCSTRING
  final String? connectionId;

  /// BEGIN LEGACY DOCSTRING
  /// initializes with [waitForSync] set to true by default
  /// END LEGACY DOCSTRING
  const RealtimePresenceParams({
    this.clientId,
    this.connectionId,
    this.waitForSync = true,
  });
}
