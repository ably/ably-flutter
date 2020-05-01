import '../enums.dart';
import '../common.dart';
import '../message.dart';


abstract class RealtimePresence {
  bool syncComplete;
  Future<List<PresenceMessage>> get([RealtimePresenceParams params]);
  Future<PaginatedResult<PresenceMessage>> history([RealtimeHistoryParams params]);
  Future<void> subscribe({
    PresenceAction action,
    List<PresenceAction> actions,
    EventListener<PresenceMessage> listener //TODO check if this is the type that is expected
  });
  void unsubscribe({
    PresenceAction action,
    List<PresenceAction> actions,
    EventListener<PresenceMessage> listener //TODO check if this is the type that is expected
  });
  Future<void> enter([dynamic data]);
  Future<void> update([dynamic data]);
  Future<void> leave([dynamic data]);
  Future<void> enterClient({String clientId, dynamic data });
  Future<void> updateClient({String clientId, dynamic data});
  Future<void> leaveClient({String clientId, dynamic data});
}


