import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../factory/reporter.dart';
import '../../utils/encoders.dart';
import '../../utils/realtime.dart';

Future<Map<String, dynamic>> testRealtimeHistory({
  Reporter reporter,
  Map<String, dynamic> payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await provision('sandbox-');
  final logMessages = <List<String>>[];

  final realtime = Realtime(
    options: ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]),
  );
  final channel = realtime.channels.get('test');
  await publishMessages(channel);

  final paginatedResult = await channel.history();
  final historyDefault = await getHistory(channel);
  await Future.delayed(const Duration(seconds: 2));

  final historyLimit4 = await getHistory(
    channel,
    RealtimeHistoryParams(limit: 4),
  );
  await Future.delayed(const Duration(seconds: 2));

  final historyLimit2 = await getHistory(
    channel,
    RealtimeHistoryParams(limit: 2),
  );
  await Future.delayed(const Duration(seconds: 2));

  final historyForwardLimit4 = await getHistory(
    channel,
    RealtimeHistoryParams(direction: 'forwards', limit: 4),
  );
  await Future.delayed(const Duration(seconds: 2));

  final time1 = DateTime.now();
  //TODO(tiholic) iOS fails without this delay
  // - timestamp on message retrieved from history
  // is earlier than expected when ran in CI
  await Future.delayed(const Duration(seconds: 2));
  await channel.publish(name: 'history', data: 'test');
  //TODO(tiholic) understand why tests fail without this delay
  await Future.delayed(const Duration(seconds: 2));

  final time2 = DateTime.now();
  await Future.delayed(const Duration(seconds: 2));
  await channel.publish(name: 'history', data: 'test2');
  await Future.delayed(const Duration(seconds: 2));

  final historyWithStart = await getHistory(
    channel,
    RealtimeHistoryParams(start: time1),
  );
  final historyWithStartAndEnd = await getHistory(
    channel,
    RealtimeHistoryParams(start: time1, end: time2),
  );
  final historyAll = await getHistory(channel);
  return {
    'handle': await realtime.handle,
    'paginatedResult': encodePaginatedResult(paginatedResult, encodeMessage),
    'historyDefault': historyDefault,
    'historyLimit4': historyLimit4,
    'historyLimit2': historyLimit2,
    'historyForwardLimit4': historyForwardLimit4,
    'historyWithStart': historyWithStart,
    'historyWithStartAndEnd': historyWithStartAndEnd,
    'historyAll': historyAll,
    't1': time1.toIso8601String(),
    't2': time2.toIso8601String(),
    'log': logMessages,
  };
}
