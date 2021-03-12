import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/rest.dart';

Future<Map<String, dynamic>> testRestPublish({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  reporter.reportLog('init start');
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
  await publishMessages(rest.channels.get('test'));
  return {
    'handle': await rest.handle,
    'log': logMessages,
  };
}
