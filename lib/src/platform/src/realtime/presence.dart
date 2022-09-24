import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// BEGIN LEGACY DOCSTRING
/// Presence object on a [RealtimeChannel] helps to query
/// Presence members and presence history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTP1
/// END LEGACY DOCSTRING

/// BEGIN CANONICAL DOCSTRING
/// Enables the presence set to be entered and subscribed to, and the historic
/// presence set to be retrieved for a channel.
/// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves the current members present on the channel and the metadata for
  /// each member, such as their [PresenceAction]{@link PresenceAction} and ID.
  /// Returns an array of [PresenceMessage]{@link PresenceMessage} objects.
  ///
  /// [waitForSync] - Sets whether to wait for a full presence set
  /// synchronization between Ably and the clients on the channel to complete
  /// before returning the results. Synchronization begins as soon as the
  /// channel is [ATTACHED]{@link ChannelState#ATTACHED}. When set to true the
  /// results will be returned as soon as the sync is complete. When set to
  /// false the current list of members will be returned without the sync
  /// completing. The default is true.
  /// [clientId] - Filters the array of returned presence members by a specific
  /// client using its ID.
  /// [connectionId] - Filters the array of returned presence members by a
  /// specific connection using its ID.
  ///
  /// [PresenceMessage] - 	An array of [PresenceMessage]{@link PresenceMessage
  /// objects.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// Retrieves a [PaginatedResult]{@link PaginatedResult} object, containing an
  /// array of historical [PresenceMessage]{@link PresenceMessage} objects for
  /// the channel. If the channel is configured to persist messages, then
  /// presence messages can be retrieved from history for up to 72 hours in the
  /// past. If not, presence messages can only be retrieved from history for up
  /// to two minutes in the past.
  ///
  /// [start] - The time from which messages are retrieved, specified as
  /// milliseconds since the Unix epoch.
  /// [end] - The time until messages are retrieved, specified as milliseconds
  /// since the Unix epoch.
  /// [direction] - The order for which messages are returned in. Valid values
  /// are backwards which orders messages from most recent to oldest, or
  /// forwards which orders messages from oldest to most recent. The default is
  /// backwards.
  /// [limit] - An upper limit on the number of messages returned. The default
  /// is 100, and the maximum is 1000.
  ///
  /// [PaginatedResult<PresenceMessage>] - A
  /// [PaginatedResult]{@link PaginatedResult} object containing an array of
  /// [PresenceMessage]{@link PresenceMessage} objects.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// Indicates whether the presence set synchronization between Ably and the
  /// clients on the channel has been completed. Set to true when the sync is
  /// complete.
  /// END CANONICAL DOCSTRING
  bool? syncComplete;

  String? get _realtimeClientId => _channel.realtime.options.clientId;

  /// BEGIN LEGACY DOCSTRING
  /// Enters the current client into this channel, optionally with the data
  /// and/or extras provided
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP8
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Enters the presence set for the channel, optionally passing a data
  /// payload. A clientId is required to be present on a channel. An optional
  /// callback may be provided to notify of the success or failure of the
  /// operation.
  ///
  /// [Data] - 	The payload associated with the presence member.
  /// [extras] - A JSON object of arbitrary key-value pairs that may contain
  /// metadata, and/or ancillary payloads.
  /// END CANONICAL DOCSTRING
  Future<void> enter([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await enterClient(_realtimeClientId!, data);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Enter the specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Enters the presence set of the channel for a given clientId. Enables a
  /// single client to update presence on behalf of any number of clients using
  /// a single connection. The library must have been instantiated with an API
  /// key or a token bound to a wildcard clientId. An optional callback may be
  /// provided to notify of the success or failure of the operation.
  ///
  /// [clientId] - The ID of the client to enter into the presence set.
  /// [Data] - The payload associated with the presence member.
  /// [extras] - A JSON object of arbitrary key-value pairs that may contain
  /// metadata, and/or ancillary payloads.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// Updates the data payload for a presence member. If called before entering
  /// the presence set, this is treated as an
  /// [ENTER]{@link PresenceAction#ENTER} event. An optional callback may be
  /// provided to notify of the success or failure of the operation.
  ///
  /// [Data] - The payload to update for the presence member.
  /// [extras] - A JSON object of arbitrary key-value pairs that may contain
  /// metadata, and/or ancillary payloads.
  /// END CANONICAL DOCSTRING
  Future<void> update([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await updateClient(_realtimeClientId!, data);
  }

  /// BEGIN LEGACY DOCSTRING
  /// Update the presence data for a specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  /// END LEGACY DOCSTRING

  /// BEGIN CANONICAL DOCSTRING
  /// Updates the data payload for a presence member using a given clientId.
  /// Enables a single client to update presence on behalf of any number of
  /// clients using a single connection. The library must have been instantiated
  /// with an API key or a token bound to a wildcard clientId. An optional
  /// callback may be provided to notify of the success or failure of the
  /// operation.
  ///
  /// [clientId] - The ID of the client to update in the presence set.
  /// [Data] - The payload to update for the presence member.
  /// [extras] - A JSON object of arbitrary key-value pairs that may contain
  /// metadata, and/or ancillary payloads.
  /// END CANONICAL DOCSTRING
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

  /// BEGIN CANONICAL DOCSTRING
  /// Leaves the presence set for the channel. A client must have previously
  /// entered the presence set before they can leave it. An optional callback
  /// may be provided to notify of the success or failure of the operation.
  ///
  /// [Data] - The payload associated with the presence member.
  /// [extras] - A JSON object of arbitrary key-value pairs that may contain
  /// metadata, and/or ancillary payloads.
  /// END CANONICAL DOCSTRING
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
  /// Leaves the presence set of the channel for a given clientId. Enables a
  /// single client to update presence on behalf of any number of clients using
  /// a single connection. The library must have been instantiated with an API
  /// key or a token bound to a wildcard clientId. An optional callback may be
  /// provided to notify of the success or failure of the operation.
  ///
  /// [clientId] - The ID of the client to leave the presence set for.
  /// [Data] - The payload associated with the presence member.
  /// [extras] - A JSON object of arbitrary key-value pairs that may contain
  /// metadata, and/or ancillary payloads.
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

  /// BEGIN CANONICAL DOCSTRING
  /// Registers a listener that is called each time a
  /// [PresenceMessage]{@link PresenceMessage} matching a given
  /// [PresenceAction]{@link PresenceAction}, or an action within an array of
  /// [PresenceActions]{@link PresenceAction}, is received on the channel, such
  /// as a new member entering the presence set. A callback may optionally be
  /// passed in to this call to be notified of success or failure of the channel
  /// [attach()]{@link RealtimeChannel#attach} operation.
  ///
  /// [PresenceAction | [PresenceAction]] - A
  /// [PresenceAction]{@link PresenceAction} or an array of
  /// [PresenceActions]{@link PresenceAction} to register the listener for.
  /// [(PresenceMessage)] - An event listener function.
  /// END CANONICAL DOCSTRING
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
