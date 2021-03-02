import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../test_dispatcher.dart';
import 'realtime_publish_test.dart';

Future<Map<String, dynamic>> testRealtimePublishWithAuthCallback({
  TestDispatcherState dispatcher,
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
  await realtimeMessagesPublishUtil(realtime.channels.get('test'));
  await realtime.close();

  return {
    'handle': await realtime.handle,
    'authCallbackInvoked': authCallbackInvoked,
  };
}
