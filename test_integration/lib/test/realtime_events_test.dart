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

    recordConnectionState();
    realtime.connection
        .on()
        .listen((e) => connectionStateChanges.add(connectionEventToJson(e)));
    realtime.connection.on(ConnectionEvent.connected).listen(
        (e) => filteredConnectionStateChanges.add(connectionEventToJson(e)));

    widget.dispatcher.reportLog({'before realtime.connect': ''});
    recordConnectionState();
    await realtime.connect();
    widget.dispatcher.reportLog({'after realtime.connect': ''});
    recordConnectionState();

    final channel = await realtime.channels.get('events-test');
    void recordChannelState() =>
        channelStates.add(enumValueToString(channel.state));

    recordChannelState();
    channel.on().listen((e) => channelStateChanges.add(channelEventToJson(e)));
    channel
        .on(ChannelEvent.attaching)
        .listen((e) => filteredChannelStateChanges.add(channelEventToJson(e)));
    recordChannelState();

    widget.dispatcher.reportLog({'before channel.attach': ''});
    await channel.attach();
    recordChannelState();
    widget.dispatcher.reportLog({'after channel.attach': ''});
    widget.dispatcher.reportLog({'before channel.detach': ''});
    await channel.detach();
    recordChannelState();
    widget.dispatcher.reportLog({'after channel.detach': ''});
    recordConnectionState();

    // TODO(tiholic) throws UnimplementedError
    // widget.dispatcher.reportLog({'before connection.close': ''});
    // await realtime.connection.close();
    // widget.dispatcher.reportLog({'after connection.close': ''});

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
