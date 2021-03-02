import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../config/data.dart';
import '../test_dispatcher.dart';

Future<Map<String, dynamic>> testRealtimePublish({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
  final appKey = await provision('sandbox-');
  final logMessages = <List<String>>[];

  final realtime = Realtime(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose
      ..logHandler = ({msg, exception}) => logMessages.add([msg, '$exception']),
  );
  await realtimeMessagesPublishUtil(realtime.channels.get('test'));
  await realtime.close();
  return {
    'handle': await realtime.handle,
    'log': logMessages,
  };
}

Future<void> realtimeMessagesPublishUtil(RealtimeChannel channel) async {
  for (final data in messagesToPublish) {
    await channel.publish(name: data[0] as String, data: data[1]);
  }
}
