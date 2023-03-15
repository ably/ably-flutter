import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';

Future<Map<String, dynamic>> testRealtimeAuthroize({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');

  String wrongChannel = "wrongchannel";
  String rightChannel = "rightchannel";
  String testClientId = "testClientId";

  final appKey = await AppProvisioning().provisionApp();

  //init ably for token
  final clientOptionsForToken = ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: testClientId,
      logLevel: LogLevel.verbose,
    );

  final ablyForToken = Rest(
    options: clientOptionsForToken,
  );

  /* get first token */
  final firstTokenParams = TokenParams(capability: "${wrongChannel}:*,"
      "clientId:${testClientId}");


  final firstToken = await ablyForToken.auth?.requestToken(tokenParams: firstTokenParams);
  final clientOptions = ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.verbose,
      useTokenAuth: true,
      autoConnect: false,
      tokenDetails: firstToken
  );
  final realtime = Realtime(options: clientOptions);
  await realtime.connect();
  final channel = realtime.channels.get(rightChannel);
  await channel.attach();


  /* get second token */
  final secondTokenParams = TokenParams(capability: "{${rightChannel}:*, "
      "${wrongChannel}:*"
      "clientId:${testClientId}}");
  final secondtoken = await ablyForToken.auth?.requestToken(tokenParams: secondTokenParams);

  /* reauthorize */
 final authOptions = AuthOptions(key: appKey, tokenDetails: secondtoken);
 final tokenDetails = await realtime.auth?.authorize(authOptions:
  authOptions);
 print(tokenDetails);
  return {
    'handle': await realtime.handle
  };
}
