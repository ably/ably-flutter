import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testRestCreateTokenRequest({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final clientOptionsForToken = ClientOptions(
    key: appKey,
    environment: 'sandbox',
    logLevel: LogLevel.verbose,
  );

  final rest = Rest(
    options: clientOptionsForToken,
  );
  final request = rest.auth?.createTokenRequest();
  if (request == null) {
    throw Error();
  }
  return {'handle': await rest.handle};
}
