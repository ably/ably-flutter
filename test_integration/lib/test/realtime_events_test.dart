import 'package:ably_flutter/ably_flutter.dart';

import '../test_dispatcher.dart';
import 'app_key_provision_helper.dart';
import 'encoders.dart';
import 'test_widget_abstract.dart';

class RealtimeEventsTest extends TestWidget {
  const RealtimeEventsTest(TestDispatcherState dispatcher) : super(dispatcher);

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
      .listen((e) => connectionStateChanges.add(encodeConnectionEvent(e)));
    realtime.connection.on(ConnectionEvent.connected).listen(
        (e) => filteredConnectionStateChanges.add(encodeConnectionEvent(e)));

    widget.dispatcher.reportLog({'before realtime.connect': ''});
    recordConnectionState(); //connection: initialized
    await realtime.connect();
    widget.dispatcher.reportLog({'after realtime.connect': ''});

    final channel = realtime.channels.get('events-test');
    void recordChannelState() =>
      channelStates.add(enumValueToString(channel.state));

    recordChannelState(); // channel: initialized
    channel.on().listen((e) => channelStateChanges.add(encodeChannelEvent(e)));
    channel
      .on(ChannelEvent.attaching)
      .listen((e) => filteredChannelStateChanges.add(encodeChannelEvent(e)));
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
      await Future.delayed(const Duration(seconds: 2));
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

}
