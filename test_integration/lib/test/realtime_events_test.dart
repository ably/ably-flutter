import 'package:ably_flutter_plugin/ably.dart';
import 'package:flutter/widgets.dart';

import '../test_dispatcher.dart';
import 'appkey_provision_helper.dart';

class RealtimeEventsTest extends StatefulWidget {
  final TestDispatcherState dispatcher;

  const RealtimeEventsTest(this.dispatcher, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RealtimeEventsTestState();
}

class RealtimeEventsTestState extends State<RealtimeEventsTest> {
  @override
  void initState() {
    super.initState();
    // widget.dispatcher.timeout(const Duration(seconds: 3));
    init();
  }

  Future<void> init() async {
    final appKey = await provision('sandbox-');

    final connectionStates = <Map<String, dynamic>>[];
    final filteredConnectionStates = <Map<String, dynamic>>[];
    final channelStates = <Map<String, dynamic>>[];
    final filteredChannelStates = <Map<String, dynamic>>[];

    final realtime = Realtime(
      options: ClientOptions.fromKey('$appKey')
        ..environment = 'sandbox'
        ..clientId = 'someClientId'
        ..autoConnect = false,
    );

    realtime.connection
        .on()
        .listen((e) => connectionStates.add(connectionEventToJson(e)));

    realtime.connection
        .on(ConnectionEvent.closing)
        .listen((e) => filteredConnectionStates.add(connectionEventToJson(e)));

    final channel = await realtime.channels.get('events-test');

    channel.on().listen((e) => channelStates.add(channelEventToJson(e)));

    channel
        .on(ChannelEvent.attaching)
        .listen((e) => filteredChannelStates.add(channelEventToJson(e)));

    final name = 'Hello';
    final data = 'Flutter';

    widget.dispatcher.reportLog({'before realtime.connect': ''});
    await realtime.connect();
    widget.dispatcher.reportLog({'after realtime.connect': ''});
    await channel.publish(name: name, data: data);
    await channel.publish(name: name);

    widget.dispatcher.reportLog({'before channel.detach': ''});
    await channel.detach();
    widget.dispatcher.reportLog({'after channel.detach': ''});
    widget.dispatcher.reportLog({'before channel.attach': ''});
    await channel.attach();
    widget.dispatcher.reportLog({'after channel.attetach': ''});

    widget.dispatcher.reportLog({'before connection.close': ''});
    // TODO(zoechi) throws UnimplementedError
    // await realtime.connection.close();
    widget.dispatcher.reportLog({'after connection.close': ''});

    widget.dispatcher.reportTestCompletion(<String, dynamic>{
      'connectionStates': connectionStates,
      'filteredConnectionStates': filteredConnectionStates,
      'channelStates': channelStates,
      'filteredChannelStates': filteredChannelStates,
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

  @override
  Widget build(BuildContext context) => Container();
}

String enumValueToString(dynamic value) =>
    value.toString().substring(value.toString().indexOf('.') + 1);
