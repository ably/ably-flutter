import 'package:ably_flutter/src/impl/platform_object.dart';
import 'package:ably_flutter/src/spec/common.dart';
import 'package:ably_flutter/src/spec/push_notifications/admin/push_admin.dart';

import '../../../ably_flutter.dart';
import '../../spec/push_notifications/push.dart';

class PushNative extends PlatformObject implements Push {
  final int _handle;

  ///
  PushNative(this._handle) : super();

  @override
  Future<DeviceDetails> activate() {
    return invokeRequest<DeviceDetails>(PlatformMethod.ac, {
      TxTransportKeys.channelName: _channel.name,
      TxTransportKeys.clientId: clientId,
      if (data != null) TxTransportKeys.data: MessageData.fromValue(data),
    });
  }

  @override
  Future<String> deactivate() {
    // TODO: implement deactivate
    throw UnimplementedError();
  }

  @override
  PushAdmin? admin;

  @override
  Future<int?> createPlatformInstance() async {
    // if (_client is Realtime) {
    //   return (_client as Realtime).handle;
    // }
    return _handle;
  }
}
