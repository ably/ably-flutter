import 'package:ably_flutter/ably_flutter.dart';

import '../test_dispatcher.dart';
import 'app_key_provision_helper.dart';
import 'data.dart';
import 'encoders.dart';
import 'test_widget_abstract.dart';

class RealtimePresenceHistoryTest extends TestWidget {
  const RealtimePresenceHistoryTest(TestDispatcherState dispatcher)
      : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() =>
      RealtimePresenceHistoryTestState();
}

class RealtimePresenceHistoryTestState
    extends TestWidgetState<RealtimePresenceHistoryTest> {
  @override
  Future<void> test() async {
    widget.dispatcher.reportLog('init start');
    final appKey = await provision('sandbox-');
    final logMessages = <List<String>>[];

    final options = ClientOptions.fromKey(appKey.toString())
      ..environment = 'sandbox'
      ..clientId = 'someClientId'
      ..logLevel = LogLevel.verbose
      ..logHandler =
          ({msg, exception}) => logMessages.add([msg, exception.toString()]);

    final realtime = Realtime(options: options);
    final channel = realtime.channels.get('test');

    final historyInitial = await _history(channel);

    // creating presence history on channel
    final realtimePresence = channel.presence;
    // single client enters channel
    await realtimePresence.enter(messagesToPublish.first[1]);
    // updates, multiple times with different messages
    for (var i = 1; i < messagesToPublish.length - 1; i++) {
      await realtimePresence.update(messagesToPublish[i][1]);
    }
    // leaves channel
    await realtimePresence.leave(messagesToPublish.last[1]);

    final historyDefault = await _history(channel);
    await Future.delayed(const Duration(seconds: 2));

    final historyLimit4 =
        await _history(channel, RealtimeHistoryParams(limit: 4));
    await Future.delayed(const Duration(seconds: 2));

    final historyLimit2 =
        await _history(channel, RealtimeHistoryParams(limit: 2));
    await Future.delayed(const Duration(seconds: 2));

    final historyForwards = await _history(
      channel,
      RealtimeHistoryParams(direction: 'forwards'),
    );
    await Future.delayed(const Duration(seconds: 2));

    final time1 = DateTime.now();
    //TODO(tiholic) iOS fails without this delay
    // - timestamp on message retrieved from history
    // is earlier than expected when ran in CI
    await Future.delayed(const Duration(seconds: 2));
    await realtimePresence.enter('enter-start-time');
    // TODO(tiholic) understand why tests fail without this delay
    await Future.delayed(const Duration(seconds: 2));

    final time2 = DateTime.now();
    await Future.delayed(const Duration(seconds: 2));
    await realtimePresence.leave('leave-end-time');
    await Future.delayed(const Duration(seconds: 2));

    final historyWithStart =
        await _history(channel, RealtimeHistoryParams(start: time1));
    final historyWithStartAndEnd = await _history(
      channel,
      RealtimeHistoryParams(start: time1, end: time2),
    );
    final historyAll = await _history(channel);

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await realtime.handle,
      'historyInitial': historyInitial,
      'historyDefault': historyDefault,
      'historyLimit4': historyLimit4,
      'historyLimit2': historyLimit2,
      'historyForwards': historyForwards,
      'historyWithStart': historyWithStart,
      'historyWithStartAndEnd': historyWithStartAndEnd,
      'historyAll': historyAll,
      'log': logMessages,
    });
  }

  Future<List<Map<String, dynamic>>> _history(
    RealtimeChannel channel, [
    RealtimeHistoryParams params,
  ]) async {
    var results = await channel.presence.history(params);
    final messages =
        encodeList<PresenceMessage>(results.items, encodePresenceMessage);
    while (results.hasNext()) {
      results = await results.next();
      messages.addAll(
        encodeList<PresenceMessage>(results.items, encodePresenceMessage),
      );
    }
    return messages;
  }
}
