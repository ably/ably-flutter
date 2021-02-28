import 'package:ably_flutter/ably_flutter.dart';

import '../test_dispatcher.dart';
import 'app_key_provision_helper.dart';
import 'encoders.dart';
import 'test_widget_abstract.dart';

class RestPresenceTest extends TestWidget {
  const RestPresenceTest(TestDispatcherState dispatcher) : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() => RestPresenceTestState();
}

class RestPresenceTestState extends TestWidgetState<RestPresenceTest> {
  @override
  Future<void> test() async {
    widget.dispatcher.reportLog('init start');
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
    final channel = rest.channels.get('test');

    final historyDefault = await _history(channel);
    await Future.delayed(const Duration(seconds: 2));

    final historyLimit4 = await _history(channel, RestHistoryParams(limit: 4));
    await Future.delayed(const Duration(seconds: 2));

    final historyLimit2 = await _history(channel, RestHistoryParams(limit: 2));
    await Future.delayed(const Duration(seconds: 2));

    final historyForwards = await _history(
      channel,
      RestHistoryParams(direction: 'forwards'),
    );
    await Future.delayed(const Duration(seconds: 2));

    // TODO use realtime to update presence members and verify
    //  See rest_history_test on how to handle the necessary

    final time1 = DateTime.now();
    //TODO(tiholic) iOS fails without this delay
    // - timestamp on message retrieved from history
    // is earlier than expected when ran in CI
    await Future.delayed(const Duration(seconds: 2));
    // TODO(tiholic) use realtime to enter channel as a new client
    // TODO(tiholic) understand why tests fail without this delay
    await Future.delayed(const Duration(seconds: 2));

    final time2 = DateTime.now();
    await Future.delayed(const Duration(seconds: 2));
    // TODO(tiholic) use realtime to enter channel as a new client
    await Future.delayed(const Duration(seconds: 2));

    final historyWithStart =
        await _history(channel, RestHistoryParams(start: time1));
    final historyWithStartAndEnd =
        await _history(channel, RestHistoryParams(start: time1, end: time2));
    final historyAll = await _history(channel);

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await rest.handle,
      'historyDefault': historyDefault,
      'historyLimit4': historyLimit4,
      'historyLimit2': historyLimit2,
      'historyWithStart': historyWithStart,
      'historyWithStartAndEnd': historyWithStartAndEnd,
      'historyAll': historyAll,
      'log': logMessages,
    });
  }

  Future<List<Map<String, dynamic>>> _history(
    RestChannel channel, [
    RestHistoryParams params,
  ]) async {
    var results = await channel.presence.history(params);
    final messages =
        encodeList<PresenceMessage>(results.items, encodePresenceMessage);
    while (results.hasNext()) {
      results = await results.next();
      messages.addAll(
          encodeList<PresenceMessage>(results.items, encodePresenceMessage));
    }
    return messages;
  }
}
