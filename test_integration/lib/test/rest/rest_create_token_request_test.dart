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
  const tokenParams = TokenParams(
      ttl: 20000,
      capability: '{"testchannel":["publish"]}',
      clientId: 'testclient');

  final authOptions = AuthOptions(
      key: appKey,
      useTokenAuth: true,
      authMethod: 'GET',
      authHeaders: {'heardkey': 'headervalue'},
      authUrl: 'bogus',
      authParams: {'paramkey': 'paramvalue'});
  final request = await rest.auth
      .createTokenRequest(authOptions: authOptions, tokenParams: tokenParams);
  if (request.ttl != tokenParams.ttl ||
      request.clientId != tokenParams.clientId ||
      request.capability != tokenParams.capability) {
    throw Error();
  }

  return {
    'handle': await rest.handle,
  };
}
