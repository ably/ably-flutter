import 'package:ably_flutter_integration_test/test/test_widget_abstract.dart';
import 'package:ably_flutter_plugin/ably.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RealtimeEventsTest extends TestWidget {
  RealtimeEventsTest(TestDispatcherState dispatcher) : super(dispatcher);

  @override
  TestWidgetState<TestWidget> createState() => RealtimeEventsTestState();
}

class RealtimeEventsTestState extends TestWidgetState<RealtimeEventsTest> {
  @override
  Future<void> test() async {
    final appKey = await provision('sandbox-');

    final connectionStates = <String>[];
    final connectionStateChanges = <Map<String, dynamic>>[];
    final filteredConnectionStateChanges = <Map<String, dynamic>>[];

    final channelStates = <String>[];
    final channelStateChanges = <Map<String, dynamic>>[];
    final filteredChannelStateChanges = <Map<String, dynamic>>[];

    final realtime = Realtime(
      options: ClientOptions.fromKey(appKey.toString())
        ..environment = 'sandbox'
        ..clientId = 'someClientId'
        ..autoConnect = false,
    );

    void recordConnectionState() =>
      connectionStates.add(enumValueToString(realtime.connection.state));

    recordConnectionState(); //connection: initialized
    realtime.connection
      .on()
      .listen((e) => connectionStateChanges.add(connectionEventToJson(e)));
    realtime.connection.on(ConnectionEvent.connected).listen(
        (e) => filteredConnectionStateChanges.add(connectionEventToJson(e)));

    widget.dispatcher.reportLog({'before realtime.connect': ''});
    recordConnectionState(); //connection: initialized
    await realtime.connect();
    widget.dispatcher.reportLog({'after realtime.connect': ''});

    final channel = await realtime.channels.get('events-test');
    void recordChannelState() =>
      channelStates.add(enumValueToString(channel.state));

    recordChannelState(); // channel: initialized
    channel.on().listen((e) => channelStateChanges.add(channelEventToJson(e)));
    channel
      .on(ChannelEvent.attaching)
      .listen((e) => filteredChannelStateChanges.add(channelEventToJson(e)));
    recordChannelState(); // channel: initialized

    widget.dispatcher.reportLog({'before channel.attach': ''});
    await channel.attach();
    recordChannelState(); // channel: attached
    widget.dispatcher.reportLog({'after channel.attach': ''});
    widget.dispatcher.reportLog({'before channel.publish': ''});
    await channel.publish(name: 'hello', data: 'ably');
    recordChannelState(); // channel: attached
    recordConnectionState(); // connection: connected
    widget.dispatcher.reportLog({'after channel.publish': ''});
    widget.dispatcher.reportLog({'before channel.detach': ''});
    await channel.detach();
    widget.dispatcher.reportLog({'after channel.detach': ''});
    recordChannelState(); // channel: detached
    recordConnectionState(); // connection: connected
    widget.dispatcher.reportLog({'before connection.close': ''});
    await realtime.close();
    await Future.delayed(Duration.zero);
    while (realtime.connection.state != ConnectionState.closed) {
      await Future.delayed(Duration(seconds: 2));
    }
    recordChannelState(); // channel: detached
    recordConnectionState(); // connection: closed
    widget.dispatcher.reportLog({'after connection.close': ''});

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'connectionStates': connectionStates,
      'connectionStateChanges': connectionStateChanges,
      'filteredConnectionStateChanges': filteredConnectionStateChanges,
      'channelStates': channelStates,
      'channelStateChanges': channelStateChanges,
      'filteredChannelStateChanges': filteredChannelStateChanges,
    });
  }

  Map<String, dynamic> channelEventToJson(ChannelStateChange e) {
    return {
      'event': enumValueToString(e.event),
      'current': enumValueToString(e.current),
      'previous': enumValueToString(e.previous),
      'reason': e.reason.toString(),
      'resumed': e.resumed,
    };
  }

  Map<String, dynamic> connectionEventToJson(ConnectionStateChange e) {
    return {
      'event': enumValueToString(e.event),
      'current': enumValueToString(e.current),
      'previous': enumValueToString(e.previous),
      'reason': e.reason.toString(),
      'retryIn': e.retryIn,
    };
  }
}

String enumValueToString(dynamic value) =>
  value.toString().substring(value.toString().indexOf('.') + 1);
