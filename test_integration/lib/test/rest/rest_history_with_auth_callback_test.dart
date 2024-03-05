import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

Future<Map<String, dynamic>> testRestHistoryWithAuthCallback({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
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

  final channel = rest.channels.get('test');
  await publishMessages(channel);

  await channel.history();
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  return {
    'handle': await rest.handle,
    'authCallbackInvoked': authCallbackInvoked
  };
}
