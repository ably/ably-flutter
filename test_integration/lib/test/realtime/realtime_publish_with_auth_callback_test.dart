import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimePublishWithAuthCallback({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  var authCallbackInvoked = false;
  final realtime = Realtime(
    options: ClientOptions(
      logLevel: LogLevel.error,
      authCallback: (params) async {
        authCallbackInvoked = true;
        return TokenRequest.fromMap(
          await AppProvisioning().getTokenRequest(),
        );
      },
    ),
  );
  await publishMessages(realtime.channels.get('test'));
  await realtime.close();

  return {
    'handle': await realtime.handle,
    'authCallbackInvoked': authCallbackInvoked,
  };
}
