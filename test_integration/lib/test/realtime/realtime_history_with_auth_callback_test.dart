import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimeHistoryWithAuthCallback({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  var authCallbackInvoked = false;

  final realtime = Realtime(
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

  final channel = realtime.channels.get('test');
  await publishMessages(channel);

  await channel.history();
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  return {
    'handle': await realtime.handle,
    'authCallbackInvoked': authCallbackInvoked,
  };
}
