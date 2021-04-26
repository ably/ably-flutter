import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../factory/reporter.dart';
import 'rest_publish_test.dart';

Future<Map<String, dynamic>> testRestPublishWithAuthCallback({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  reporter.reportLog('init start');
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
