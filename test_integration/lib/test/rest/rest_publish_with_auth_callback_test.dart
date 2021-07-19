import 'package:ably_flutter/ably_flutter.dart';

import '../../factory/reporter.dart';
import '../../provisioning.dart';
import '../../utils/rest.dart';

Future<Map<String, dynamic>> testRestPublishWithAuthCallback({
  required Reporter reporter,
  Map<String, dynamic>? payload,
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
  await publishMessages(rest.channels.get('test'));
  return {
    'handle': await rest.handle,
    'authCallbackInvoked': authCallbackInvoked
  };
}
