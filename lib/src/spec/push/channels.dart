import '../common.dart';

abstract class PushChannel {
  // RSH7a
  Future<void> subscribeDevice();

  // RSH7b
  Future<void> subscribeClient();

  // RSH7c
  Future<void> unsubscribeDevice();

  // RSH7d
  Future<void> unsubscribeClient();

  // RSH7e
  Future<PaginatedResultInterface<PushChannelSubscription>> listSubscriptions();
}
