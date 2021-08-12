import 'dart:async';

import '../common.dart';
import '../enums.dart';
import '../message.dart';
import 'channels.dart';

/// Presence object on a [RealtimeChannelInterface] helps to query
/// Presence members and presence history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTP1
abstract class RealtimePresenceInterface {
  /// Returns true when the initial member SYNC following
  /// channel attach is completed.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP13
  bool? syncComplete;

  /// Get the presence members for this Channel.
  ///
  /// filters the results if [params] are passed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11
  Future<List<PresenceMessage>> get([RealtimePresenceParams? params]);

  /// Return the presence messages history for the channel as a PaginatedResult
  ///
  /// filters the results if [params] are passed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP12
  Future<PaginatedResultInterface<PresenceMessage>> history([
    RealtimeHistoryParams? params,
  ]);

  /// subscribes to presence messages on a realtime channel
  ///
  /// there is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be cancelled
  /// by calling [StreamSubscription.cancel]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP6
  Stream<PresenceMessage?> subscribe({
    PresenceAction? action,
    List<PresenceAction>? actions,
  });

  /// Enters the current client into this channel, optionally with the data
  /// and/or extras provided
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP8
  Future<void> enter([Object? data]);

  /// Enter the specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  Future<void> enterClient(String clientId, [Object? data]);

  /// Update the presence data for this client.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP9
  Future<void> update([Object? data]);

  /// Update the presence data for a specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  Future<void> updateClient(String clientId, [Object? data]);

  /// Leave this client from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP10
  Future<void> leave([Object? data]);

  /// Leave a given client_id from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  Future<void> leaveClient(String clientId, [Object? data]);
}
