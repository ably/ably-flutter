import 'dart:collection';

import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';


Future<Map<String, dynamic>> testRealtimeAuthroize({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');

  const rightChannel = "rightchannel";

  final appKey = await AppProvisioning().provisionApp();

  //init ably for token
  final clientOptionsForToken = ClientOptions(
      key: appKey,
      environment: 'sandbox',
      logLevel: LogLevel.verbose,
    );

  final ablyForToken = Rest(
    options: clientOptionsForToken,
  );
  /* get first token */
  final firstToken = await ablyForToken.auth?.requestToken();

  final clientOptions = ClientOptions(
      key: appKey,
      environment: 'sandbox',
      useTokenAuth: true,
      autoConnect: false,
      tokenDetails: firstToken
  );
  final realtime = Realtime(options: clientOptions);
  await realtime.connect();
  final channel = realtime.channels.get(rightChannel);
  await channel.attach();

  final refreshedToken = await realtime.auth?.authorize();
  if (refreshedToken == firstToken){
    throw Error();
  }
  return {
    'handle': await realtime.handle
  };
}
