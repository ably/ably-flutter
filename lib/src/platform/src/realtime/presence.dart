import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Presence object on a [RealtimeChannel] helps to query
/// Presence members and presence history
///
/// https://docs.ably.com/client-lib-development-guide/features/#RTP1
class RealtimePresence extends PlatformObject {
  final RealtimeChannel _channel;

  /// instantiates with a channel
  RealtimePresence(this._channel);

  @override
  Future<int> createPlatformInstance() => _channel.realtime.handle;

  /// Get the presence members for this Channel.
  ///
  /// filters the results if [params] are passed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP11
  Future<List<PresenceMessage>> get([
    RealtimePresenceParams? params,
  ]) async {
    final presenceMessages = await invokeRequest<List>(
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

  /// Return the presence messages history for the channel as a PaginatedResult
  ///
  /// filters the results if [params] are passed
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP12
  Future<PaginatedResult<PresenceMessage>> history([
    RealtimeHistoryParams? params,
  ]) async {
    final message = await invokeRequest<AblyMessage>(
      PlatformMethod.realtimePresenceHistory,
      {
        TxTransportKeys.channelName: _channel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(
      AblyMessage.castFrom<dynamic, PaginatedResult>(message),
    );
  }

  /// Returns true when the initial member SYNC following
  /// channel attach is completed.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP13
  bool? syncComplete;

  String? get _realtimeClientId => _channel.realtime.options.clientId;

  /// Enters the current client into this channel, optionally with the data
  /// and/or extras provided
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP8
  Future<void> enter([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await enterClient(_realtimeClientId!, data);
  }

  /// Enter the specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  Future<void> enterClient(String clientId, [Object? data]) async {
    await invoke(PlatformMethod.realtimePresenceEnter, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// Update the presence data for this client.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP9
  Future<void> update([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await updateClient(_realtimeClientId!, data);
  }

  /// Update the presence data for a specified client_id into this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  Future<void> updateClient(String clientId, [Object? data]) async {
    await invoke(PlatformMethod.realtimePresenceUpdate, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// Leave this client from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP10
  Future<void> leave([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await leaveClient(_realtimeClientId!, data);
  }

  /// Leave a given client_id from this channel.
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP15
  Future<void> leaveClient(String clientId, [Object? data]) async {
    await invoke(PlatformMethod.realtimePresenceLeave, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  /// subscribes to presence messages on a realtime channel
  ///
  /// there is no unsubscribe api in flutter like in other Ably client SDK's
  /// as subscribe returns a stream which can be cancelled
  /// by calling [StreamSubscription.cancel]
  ///
  /// https://docs.ably.com/client-lib-development-guide/features/#RTP6
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
