import '../common.dart';
import '../message.dart';

class Presence {
  Future<PaginatedResultInterface<PresenceMessage>> get(
      [RestPresenceParams params]) {
    throw UnimplementedError();
  }

  Future<PaginatedResultInterface<PresenceMessage>> history(
      [RestHistoryParams params]) {
    throw UnimplementedError();
  }
}
