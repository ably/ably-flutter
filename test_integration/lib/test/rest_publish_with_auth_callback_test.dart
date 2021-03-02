import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../test_dispatcher.dart';
import 'rest_publish_test.dart';

Future<Map<String, dynamic>> testRestPublishWithAuthCallback({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  dispatcher.reportLog('init start');
  var authCallbackInvoked = false;
  final rest = Rest(
      options: ClientOptions()
        ..clientId = 'someClientId'
        ..logLevel = LogLevel.verbose
        ..authCallback = ((params) async {
          authCallbackInvoked = true;
          return TokenRequest.fromMap(await getTokenRequest());
        }));
  await restMessagesPublishUtil(rest.channels.get('test'));
  return {
    'handle': await rest.handle,
    'authCallbackInvoked': authCallbackInvoked
  };
}
