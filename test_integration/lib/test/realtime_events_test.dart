import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../config/encoders.dart';
import '../test_dispatcher.dart';

Future<Map<String, dynamic>> testRealtimeEvents({
  TestDispatcherState dispatcher,
  Map<String, dynamic> payload,
}) async {
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

  dispatcher.reportLog({'before realtime.connect': ''});
  recordConnectionState(); //connection: initialized
  await realtime.connect();
  dispatcher.reportLog({'after realtime.connect': ''});

  final channel = realtime.channels.get('events-test');
  void recordChannelState() =>
      channelStates.add(enumValueToString(channel.state));

  recordChannelState(); // channel: initialized
  channel.on().listen((e) => channelStateChanges.add(encodeChannelEvent(e)));
  channel
      .on(ChannelEvent.attaching)
      .listen((e) => filteredChannelStateChanges.add(encodeChannelEvent(e)));
  recordChannelState(); // channel: initialized

  dispatcher.reportLog({'before channel.attach': ''});
  await channel.attach();
  recordChannelState(); // channel: attached
  dispatcher
    ..reportLog({'after channel.attach': ''})
    ..reportLog({'before channel.publish': ''});
  await channel.publish(name: 'hello', data: 'ably');
  recordChannelState(); // channel: attached
  recordConnectionState(); // connection: connected
  dispatcher
    ..reportLog({'after channel.publish': ''})
    ..reportLog({'before channel.detach': ''});
  await channel.detach();
  dispatcher.reportLog({'after channel.detach': ''});
  recordChannelState(); // channel: detached
  recordConnectionState(); // connection: connected
  dispatcher.reportLog({'before connection.close': ''});
  await realtime.close();
  await Future.delayed(Duration.zero);
  while (realtime.connection.state != ConnectionState.closed) {
    await Future.delayed(const Duration(seconds: 2));
  }
  recordChannelState(); // channel: detached
  recordConnectionState(); // connection: closed
  dispatcher.reportLog({'after connection.close': ''});

  return {
    'connectionStates': connectionStates,
    'connectionStateChanges': connectionStateChanges,
    'filteredConnectionStateChanges': filteredConnectionStateChanges,
    'channelStates': channelStates,
    'channelStateChanges': channelStateChanges,
    'filteredChannelStateChanges': filteredChannelStateChanges,
  };
}
