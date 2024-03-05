import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

Future<Map<String, dynamic>> testRestPublishWithAuthCallback({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  var authCallbackInvoked = false;
  final rest = Rest(
    options: ClientOptions(
      clientId: 'someClientId',
      logLevel: LogLevel.error,
      authCallback: (params) async {
        authCallbackInvoked = true;
        return TokenRequest.fromMap(
          await AppProvisioning().getTokenRequest(),
        );
      },
    ),
  );
  await publishMessages(rest.channels.get('test'));
  return {
    'handle': await rest.handle,
    'authCallbackInvoked': authCallbackInvoked
  };
}
