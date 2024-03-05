import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testRealtimeAuthClientId({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  //init ably for token
  final clientOptionsForToken = ClientOptions(
    key: appKey,
    environment: 'sandbox',
    logLevel: LogLevel.error,
  );

  final ablyForToken = Rest(
    options: clientOptionsForToken,
  );
  /* get first token */
  final firstToken = await ablyForToken.auth.requestToken();

  final clientOptions = ClientOptions(
      key: appKey,
      environment: 'sandbox',
      useTokenAuth: true,
      autoConnect: false,
      clientId: 'testClientId',
      tokenDetails: firstToken);
  final realtime = Realtime(options: clientOptions);
  await realtime.connect();

  final clientId = await realtime.auth.clientId;
  if (clientId != 'testClientId') {
    throw Error();
  }
  return {'handle': await realtime.handle};
}
