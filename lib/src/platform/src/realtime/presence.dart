import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

/// Plugin based implementation of [RestPresence]
class RealtimePresence extends PlatformObject
    implements RealtimePresenceInterface {
  final RealtimeChannel _channel;

  /// instantiates with a channel
  RealtimePresence(this._channel);

  @override
  Future<int> createPlatformInstance() =>
      (_channel.realtime as Realtime).handle;

  @override
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

  @override
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

  @override
  bool? syncComplete;

  String? get _realtimeClientId => _channel.realtime.options.clientId;

  @override
  Future<void> enter([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await enterClient(_realtimeClientId!, data);
  }

  @override
  Future<void> enterClient(String clientId, [Object? data]) async {
    await invoke(PlatformMethod.realtimePresenceEnter, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Future<void> update([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await updateClient(_realtimeClientId!, data);
  }

  @override
  Future<void> updateClient(String clientId, [Object? data]) async {
    await invoke(PlatformMethod.realtimePresenceUpdate, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Future<void> leave([Object? data]) async {
    assert(_realtimeClientId != null, 'No client id specified on realtime');
    await leaveClient(_realtimeClientId!, data);
  }

  @override
  Future<void> leaveClient(String clientId, [Object? data]) async {
    await invoke(PlatformMethod.realtimePresenceLeave, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
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
