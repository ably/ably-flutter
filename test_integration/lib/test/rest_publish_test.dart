import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../config/data.dart';
import '../test_dispatcher.dart';

Future<Map<String, dynamic>> testRestPublish({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  dispatcher.reportLog('init start');
  final appKey = await provision('sandbox-');
  final logMessages = <List<String>>[];

  final rest = Rest(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]),
  );
  await restMessagesPublishUtil(rest.channels.get('test'));
  return {
    'handle': await rest.handle,
    'log': logMessages,
  };
}

Future<void> restMessagesPublishUtil(RestChannel channel) async {
  for (final data in messagesToPublish) {
    await channel.publish(name: data[0] as String, data: data[1]);
  }
}
