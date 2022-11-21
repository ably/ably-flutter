import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Enables the presence set to be entered and subscribed to, and the historic
/// presence set to be retrieved for a channel.
class RealtimePresence extends PlatformObject {
  final RealtimeChannel _channel;

  /// @nodoc
  /// instantiates with a channel
  RealtimePresence(this._channel);

  /// @nodoc
  @override
  Future<int> createPlatformInstance() => _channel.realtime.handle;

  /// Retrieves the current members present on the channel and the metadata for
  /// each member, such as their [PresenceAction] and ID, based on provided
  /// [params]. Returns an array of [PresenceMessage] objects.
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

  /// Retrieves a [PaginatedResult] object, containing an array of historical
  /// [PresenceMessage] objects for the channel, based on provided [params].
  ///
  /// If the channel is configured to persist messages, then
  /// presence messages can be retrieved from history for up to 72 hours in the
  /// past. If not, presence messages can only be retrieved from history for up
  /// to two minutes in the past.
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

  /// Whether the presence set synchronization between Ably and the
  /// clients on the channel has been completed. Set to `true` when the sync is
  /// complete.
  bool? syncComplete;

  String? get _realtimeClientId => _channel.realtime.options.clientId;

  /// Enters the presence set for the channel, optionally passing a [data]
  /// payload associated with the presence member. A clientId is required to be
  /// present on a channel.
  Future<void> enter([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await enterClient(_realtimeClientId!, data);
  }

  /// Enters the presence set of the channel for a given [clientId], which is
  /// the ID of the client to enter into the presence set. You can also pass a
  /// [data] payload associated with the presence member.
  ///
  /// Enables a single client to update presence on behalf of any number of
  /// clients using a single connection. The library must have been instantiated
  /// with an API key or a token bound to a wildcard `clientId`.
  Future<void> enterClient(String clientId, [Object? data]) async {
    await invoke<void>(PlatformMethod.realtimePresenceEnter, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// Updates the data payload for a presence member. If called before entering
  /// the presence set, this is treated as a [PresenceAction.enter] event.
  /// You can provide the [data] payload to update for the presence member.
  Future<void> update([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await updateClient(_realtimeClientId!, data);
  }

  /// Updates the [data] payload for a presence member using a given [clientId],
  /// which is the ID of a client to update in the presence set.
  ///
  /// Enables a single client to update presence on behalf of any number of
  /// clients using a single connection. The library must have been instantiated
  /// with an API key or a token bound to a wildcard `clientId`.
  Future<void> updateClient(String clientId, [Object? data]) async {
    await invoke<void>(PlatformMethod.realtimePresenceUpdate, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// Leaves the presence set for the channel. A client must have previously
  /// entered the presence set before they can leave it.
  ///
  /// You can provide the [data] payload associated with the presence member.
  Future<void> leave([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await leaveClient(_realtimeClientId!, data);
  }

  /// Leaves the presence set of the channel for a given [clientId], which is
  /// the ID of the client to leave the presence set for. You can also provide a
  /// [data] payload, associated with the presence member.
  ///
  /// Enables a single client to update presence on behalf of any number of
  /// clients using a single connection. The library must have been instantiated
  /// with an API key or a token bound to a wildcard `clientId`.
  Future<void> leaveClient(String clientId, [Object? data]) async {
    await invoke<void>(PlatformMethod.realtimePresenceLeave, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// Returns a stream that emmits a [PresenceMessage] each time a matching
  /// [action], or an action within an array of [actions], is received on the
  /// channel, such as a new member entering the presence set.
  ///
  /// There is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be used to create a
  /// cancellable stream subscription
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
