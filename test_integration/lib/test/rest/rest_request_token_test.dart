import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

Future<Map<String, dynamic>> testRestRequestToken({
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

  final restForToken = Rest(
    options: clientOptionsForToken,
  );

  final token = await restForToken.auth.requestToken();

  final clientOptions = ClientOptions(
      tokenDetails: token, environment: 'sandbox', logLevel: LogLevel.error);
  final tokenedRest = Rest(options: clientOptions);

  await publishMessages(tokenedRest.channels.get('test'));

  return {'handle': await tokenedRest.handle};
}
