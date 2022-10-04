import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// Presence object on a [RealtimeChannel] helps to query
/// Presence members and presence history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTP1
/// END LEGACY DOCSTRING

/// BEGIN EDITED CANONICAL DOCSTRING
/// Enables the presence set to be entered and subscribed to, and the historic
/// presence set to be retrieved for a channel.
/// END EDITED CANONICAL DOCSTRING
class RealtimePresence extends PlatformObject {
  final RealtimeChannel _channel;

  /// instantiates with a channel
  RealtimePresence(this._channel);

  @override
  Future<int> createPlatformInstance() => _channel.realtime.handle;

  /// BEGIN LEGACY DOCSTRING
  /// Get the presence members for this Channel.
  ///
  /// filters the results if [params] are passed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves the current members present on the channel and the metadata for
  /// each member, such as their [PresenceAction] and ID, based on provided
  /// [params]. Returns an array of [PresenceMessage] objects.
  /// END EDITED CANONICAL DOCSTRING
  Future<List<PresenceMessage>> get([
    RealtimePresenceParams? params,
  ]) async {
    final presenceMessages = await invokeRequest<List<dynamic>>(
      PlatformMethod.realtimePresenceGet,
      {
        TxTransportKeys.channelName: _channel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return presenceMessages
        .map<PresenceMessage>((e) => e as PresenceMessage)
        .toList();
  }

  /// BEGIN LEGACY DOCSTRING
  /// Return the presence messages history for the channel as a PaginatedResult
  ///
  /// filters the results if [params] are passed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP12
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Retrieves a [PaginatedResult] object, containing an array of historical
  /// [PresenceMessage] objects for the channel, based on provided [params].
  ///
  /// If the channel is configured to persist messages, then
  /// presence messages can be retrieved from history for up to 72 hours in the
  /// past. If not, presence messages can only be retrieved from history for up
  /// to two minutes in the past.
  /// END EDITED CANONICAL DOCSTRING
  Future<PaginatedResult<PresenceMessage>> history([
    RealtimeHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.realtimePresenceHistory,
      {
        TxTransportKeys.channelName: _channel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message),
    );
  }

  /// BEGIN LEGACY DOCSTRING
  /// Returns true when the initial member SYNC following
  /// channel attach is completed.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP13
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Whether the presence set synchronization between Ably and the
  /// clients on the channel has been completed. Set to `true` when the sync is
  /// complete.
  /// END EDITED CANONICAL DOCSTRING
  bool? syncComplete;

  String? get _realtimeClientId => _channel.realtime.options.clientId;

  /// BEGIN LEGACY DOCSTRING
  /// Enters the current client into this channel, optionally with the data
  /// and/or extras provided
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP8
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Enters the presence set for the channel, optionally passing a [data]
  /// payload associated with the presence member. A clientId is required to be
  /// present on a channel.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> enter([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await enterClient(_realtimeClientId!, data);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Enter the specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Enters the presence set of the channel for a given [clientId], which is
  /// the ID of the client to enter into the presence set. You can also pass a
  /// [data] payload associated with the presence member.
  ///
  /// Enables a single client to update presence on behalf of any number of
  /// clients using a single connection. The library must have been instantiated
  /// with an API key or a token bound to a wildcard `clientId`.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> enterClient(String clientId, [Object? data]) async {
    await invoke<void>(PlatformMethod.realtimePresenceEnter, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// BEGIN LEGACY DOCSTRING
  /// Update the presence data for this client.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP9
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Updates the data payload for a presence member. If called before entering
  /// the presence set, this is treated as a [PresenceAction.enter] event.
  /// You can provide the [data] payload to update for the presence member.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> update([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await updateClient(_realtimeClientId!, data);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Update the presence data for a specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Updates the [data] payload for a presence member using a given [clientId],
  /// which is the ID of a client to update in the presence set.
  ///
  /// Enables a single client to update presence on behalf of any number of
  /// clients using a single connection. The library must have been instantiated
  /// with an API key or a token bound to a wildcard `clientId`.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> updateClient(String clientId, [Object? data]) async {
    await invoke<void>(PlatformMethod.realtimePresenceUpdate, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// BEGIN LEGACY DOCSTRING
  /// Leave this client from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP10
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Leaves the presence set for the channel. A client must have previously
  /// entered the presence set before they can leave it.
  /// You can provide the [data] payload associated with the presence member.
  /// END EDITED CANONICAL DOCSTRING
  Future<void> leave([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await leaveClient(_realtimeClientId!, data);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Leave a given client_id from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Leaves the presence set of the channel for a given [clientId], which is
  /// the ID of the client to leave the presence set for. You can also provide a
  /// [data] payload, associated with the presence member.
  ///
  /// Enables a single client to update presence on behalf of any number of
  /// clients using a single connection. The library must have been instantiated
  /// with an API key or a token bound to a wildcard `clientId`.
  /// END CANONICAL DOCSTRING
  Future<void> leaveClient(String clientId, [Object? data]) async {
    await invoke<void>(PlatformMethod.realtimePresenceLeave, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// BEGIN LEGACY DOCSTRING
  /// subscribes to presence messages on a realtime channel
  ///
  /// there is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be used to create a
  /// cancellable stream subscription
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP6
  /// END LEGACY DOCSTRING

  /// BEGIN EDITED CANONICAL DOCSTRING
  /// Returns a stream that emmits a [presenceMessage]  each time a matching
  /// given [action], or an action within an array of [actions], is received
  /// on the channel, such as a new member entering the presence set.
  /// END EDITED CANONICAL DOCSTRING
  Stream<PresenceMessage> subscribe({
    PresenceAction? action,
    List<PresenceAction>? actions,
  }) {
    if (action != null) actions ??= [action];
    return listen<PresenceMessage>(PlatformMethod.onRealtimePresenceMessage, {
      TxTransportKeys.channelName: _channel.name,
    }).where((presenceMessage) =>
        actions == null || actions.contains(presenceMessage.action));
  }
}
