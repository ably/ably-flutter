import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_integration_test/app_provisioning.dart';
import 'package:ably_flutter_integration_test/config/test_constants.dart';
import 'package:ably_flutter_integration_test/factory/reporter.dart';
import 'package:ably_flutter_integration_test/utils/encoders.dart';
import 'package:ably_flutter_integration_test/utils/rest.dart';

Future<Map<String, dynamic>> testRestHistory({
  required Reporter reporter,
  Map<String, dynamic>? payload,
}) async {
  reporter.reportLog('init start');
  final appKey = await AppProvisioning().provisionApp();

  final rest = Rest(
    options: ClientOptions(
      key: appKey,
      environment: 'sandbox',
      clientId: 'someClientId',
      logLevel: LogLevel.error,
    ),
  );
  final channel = rest.channels.get('test');
  await publishMessages(channel);

  final paginatedResult = await channel.history();
  final historyDefault = await getHistory(channel);
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final historyLimit4 = await getHistory(channel, RestHistoryParams(limit: 4));
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final historyLimit2 = await getHistory(channel, RestHistoryParams(limit: 2));
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final historyForwardLimit4 = await getHistory(
      channel, RestHistoryParams(direction: 'forwards', limit: 4));
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final time1 = DateTime.now();
  //TODO(tiholic) iOS fails without this delay
  // - timestamp on message retrieved from history
  // is earlier than expected when ran in CI
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  await channel.publish(name: 'history', data: 'test');
  //TODO(tiholic) understand why tests fail without this delay
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final time2 = DateTime.now();
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);
  await channel.publish(name: 'history', data: 'test2');
  await Future<void>.delayed(TestConstants.publishToHistoryDelay);

  final historyWithStart =
      await getHistory(channel, RestHistoryParams(start: time1));
  final historyWithStartAndEnd =
      await getHistory(channel, RestHistoryParams(start: time1, end: time2));
  final historyAll = await getHistory(channel);
  return {
    'handle': await rest.handle,
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
  };
}
