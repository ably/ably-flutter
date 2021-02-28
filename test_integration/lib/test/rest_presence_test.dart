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

    final membersDefault = await _members(channel);
    await Future.delayed(const Duration(seconds: 2));

    final membersLimit4 = await _members(channel, RestPresenceParams(limit: 4));
    await Future.delayed(const Duration(seconds: 2));

    final membersLimit2 = await _members(channel, RestPresenceParams(limit: 2));
    await Future.delayed(const Duration(seconds: 2));

    final membersLimitClientId = await _members(
      channel,
      RestPresenceParams(clientId: 'client-1'),
    );
    await Future.delayed(const Duration(seconds: 2));

    final membersLimitConnectionId = await _members(
      channel,
      RestPresenceParams(connectionId: 'connection-1'),
    );
    await Future.delayed(const Duration(seconds: 2));

    // TODO use realtime to update presence members and verify
    //  See rest_history_test on how to handle the necessary

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'handle': await rest.handle,
      'membersDefault': membersDefault,
      'membersLimit4': membersLimit4,
      'membersLimit2': membersLimit2,
      'membersLimitClientId': membersLimitClientId,
      'membersLimitConnectionId': membersLimitConnectionId,
      'log': logMessages,
    });
  }

  Future<List<Map<String, dynamic>>> _members(
    RestChannel channel, [
    RestPresenceParams params,
  ]) async {
    var results = await channel.presence.get(params);
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
