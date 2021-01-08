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
  final RealtimeChannel _realtimeChannel;

  /// instantiates with a channel
  RealtimePresence(this._realtimeChannel);

  @override
  Future<int> createPlatformInstance() =>
      (_realtimeChannel.realtime as Realtime).handle;

  @override
  Future<List<PresenceMessage>> get([
    RealtimePresenceParams params,
  ]) async {
    final presenceMessages = await invoke<List>(
      PlatformMethod.realtimePresenceGet,
      {
        TxTransportKeys.channelName: _realtimeChannel.name,
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
        TxTransportKeys.channelName: _realtimeChannel.name,
        if (params != null) TxTransportKeys.params: params
      },
    );
    return PaginatedResult<PresenceMessage>.fromAblyMessage(message);
  }

  @override
  bool syncComplete;

  @override
  Future<void> enter([Object data]) => enterClient(null, data);

  @override
  Future<void> enterClient(String clientId, [Object data]) async {
    await invoke(PlatformMethod.realtimePresenceEnter, {
      TxTransportKeys.channelName: _realtimeChannel.name,
      if (clientId != null) TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Future<void> update([Object data]) => updateClient(null, data);

  @override
  Future<void> updateClient(String clientId, [Object data]) async {
    await invoke(PlatformMethod.realtimePresenceUpdate, {
      TxTransportKeys.channelName: _realtimeChannel.name,
      if (clientId != null) TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Future<void> leave([Object data]) => leaveClient(null, data);

  @override
  Future<void> leaveClient(String clientId, [Object data]) async {
    await invoke(PlatformMethod.realtimePresenceLeave, {
      TxTransportKeys.channelName: _realtimeChannel.name,
      if (clientId != null) TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Stream<PresenceMessage> subscribe({
    PresenceAction action,
    List<PresenceAction> actions,
  }) =>
      listen(PlatformMethod.realtimePresenceSubscribe)
          .map((presenceMessage) => presenceMessage as PresenceMessage)
          .where(
            (presenceMessage) =>
                action == null || presenceMessage.action == action,
          );
}
