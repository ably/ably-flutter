import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimePublish({
  Reporter reporter,
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
  await publishMessages(realtime.channels.get('test'));
  await realtime.close();
  return {
    'handle': await realtime.handle,
    'log': logMessages,
  };
}
