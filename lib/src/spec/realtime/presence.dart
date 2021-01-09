import '../common.dart';
import '../enums.dart';
import '../message.dart';

abstract class RealtimePresence {
  bool syncComplete;

  Future<List<PresenceMessage>> get([RealtimePresenceParams params]);

  Future<PaginatedResultInterface<PresenceMessage>> history([
    RealtimeHistoryParams params,
  ]);

  Future<void> subscribe({
    PresenceAction action,
    List<PresenceAction> actions,
    EventListener<PresenceMessage> listener,
    //TODO(tiholic) check if this is the expected type for listener
  });

  void unsubscribe({
    PresenceAction action,
    List<PresenceAction> actions,
    EventListener<PresenceMessage> listener,
    //TODO(tiholic) check if this is the expected type for listener
  });

  Future<void> enter([Object data]);

  Future<void> update([Object data]);

  Future<void> leave([Object data]);

  Future<void> enterClient({String clientId, Object data});

  Future<void> updateClient({String clientId, Object data});

  Future<void> leaveClient({String clientId, Object data});
}
