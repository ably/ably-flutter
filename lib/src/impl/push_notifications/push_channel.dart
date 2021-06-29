

import 'package:ably_flutter/src/impl/platform_object.dart';

class PushChannel extends PlatformObject {

  /// Subscribe device to the channel’s push notifications.
  void subscribe() {

  }

  /// Unsubscribe device from the channel’s push notifications.
  void unsubscribe() {

  }

  /// Unsubscribe all devices associated with your device’s clientId from the channel’s push notifications.
  void unsubscribeAllClientsWithCurrentClientId() {

  }

  Future<PaginatedResult<PushChannelSubscription>> listSubscriptions() {

  }



  @override
  Future<int?> createPlatformInstance() {
    // TODO: implement createPlatformInstance
    throw UnimplementedError();
  }

}