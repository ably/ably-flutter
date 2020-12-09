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
  Future<void> enter([Object data]) => throw UnimplementedError();

  @override
  Future<void> enterClient(String clientId, [Object data]) =>
      throw UnimplementedError();

  @override
  Future<void> leave([Object data]) => throw UnimplementedError();

  @override
  Future<void> leaveClient(String clientId, [Object data]) =>
      throw UnimplementedError();

  @override
  Future<Stream<PresenceMessage>> subscribe(
          {PresenceAction action,
          List<PresenceAction> actions,
          EventListener<PresenceMessage> listener}) =>
      throw UnimplementedError();

  @override
  Future<void> update([Object data]) => throw UnimplementedError();

  @override
  Future<void> updateClient(String clientId, [Object data]) =>
      throw UnimplementedError();
}
