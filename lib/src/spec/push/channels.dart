import '../common.dart';

abstract class PushChannel{
  Future<void> subscribeDevice(); // RSH7a
  Future<void> subscribeClient(); // RSH7b
  Future<void> unsubscribeDevice(); // RSH7c
  Future<void> unsubscribeClient(); // RSH7d
  Future<PaginatedResultInterface<PushChannelSubscription>> listSubscriptions(); // RSH7e
}
