import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimePublishWithAuthCallback({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  var authCallbackInvoked = false;
  final realtime = Realtime(
      options: ClientOptions()
        ..logLevel = LogLevel.verbose
        ..authCallback = ((params) async {
          authCallbackInvoked = true;
          return TokenRequest.fromMap(await getTokenRequest());
        }));
  await publishMessages(realtime.channels.get('test'));
  await realtime.close();

  return {
    'handle': await realtime.handle,
    'authCallbackInvoked': authCallbackInvoked,
  };
}
