import '../../generated/platformconstants.dart';
import '../../spec/spec.dart';
import '../message.dart';
import '../paginated_result.dart';
import '../platform_object.dart';
import 'channels.dart';
import 'realtime.dart';

/// Plugin based implementation of [RestPresenceInterface]
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
    RealtimePresenceParams params,
  ]) async {
    final presenceMessages = await invoke<List>(
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
    RealtimeHistoryParams params,
  ]) async {
    final message = await invoke<AblyMessage>(
      PlatformMethod.realtimePresenceHistory,
      {
        TxTransportKeys.channelName: _channel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(message);
  }

  @override
  bool syncComplete;

  String get _realtimeClientId => _channel.realtime.options.clientId;

  @override
  Future<void> enter([Object data]) => enterClient(_realtimeClientId, data);

  @override
  Future<void> enterClient(String clientId, [Object data]) async {
    assert(
        clientId != null,
        'Channel ${_channel.name}:'
        ' unable to enter presence channel (null clientId specified)');
    await invoke(PlatformMethod.realtimePresenceEnter, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Future<void> update([Object data]) => updateClient(_realtimeClientId, data);

  @override
  Future<void> updateClient(String clientId, [Object data]) async {
    assert(
        clientId != null,
        'Channel ${_channel.name}:'
        ' unable to update presence channel (null clientId specified)');
    await invoke(PlatformMethod.realtimePresenceUpdate, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Future<void> leave([Object data]) => leaveClient(_realtimeClientId, data);

  @override
  Future<void> leaveClient(String clientId, [Object data]) async {
    assert(
        clientId != null,
        'Channel ${_channel.name}:'
        ' unable to leave presence channel (null clientId specified)');
    await invoke(PlatformMethod.realtimePresenceLeave, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Stream<PresenceMessage> subscribe({
    PresenceAction action,
    List<PresenceAction> actions,
  }) {
    if (action != null) actions ??= [action];
    return listen<PresenceMessage>(PlatformMethod.onRealtimePresenceMessage, {
      TxTransportKeys.channelName: _channel.name,
    }).where((presenceMessage) =>
        actions == null || actions.contains(presenceMessage.action));
  }
}
