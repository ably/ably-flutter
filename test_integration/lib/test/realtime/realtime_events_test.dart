import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter_example/provisioning.dart';

import '../../config/test_config.dart';
import '../../factory/reporter.dart';
import '../../utils/encoders.dart';

Future<Map<String, dynamic>> testRealtimeEvents({
  Reporter reporter,
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

  reporter.reportLog({'before realtime.connect': ''});
  recordConnectionState(); //connection: initialized
  await realtime.connect();
  reporter.reportLog({'after realtime.connect': ''});

  final channel = realtime.channels.get('events-test');
  void recordChannelState() =>
      channelStates.add(enumValueToString(channel.state));

  recordChannelState(); // channel: initialized
  channel.on().listen((e) => channelStateChanges.add(encodeChannelEvent(e)));
  channel
      .on(ChannelEvent.attaching)
      .listen((e) => filteredChannelStateChanges.add(encodeChannelEvent(e)));
  recordChannelState(); // channel: initialized

  reporter.reportLog({'before channel.attach': ''});
  await channel.attach();
  recordChannelState(); // channel: attached
  reporter
    ..reportLog({'after channel.attach': ''})
    ..reportLog({'before channel.publish': ''});
  await channel.publish(name: 'hello', data: 'ably');
  recordChannelState(); // channel: attached
  recordConnectionState(); // connection: connected
  reporter
    ..reportLog({'after channel.publish': ''})
    ..reportLog({'before channel.detach': ''});
  await channel.detach();
  reporter.reportLog({'after channel.detach': ''});
  recordChannelState(); // channel: detached
  recordConnectionState(); // connection: connected
  reporter.reportLog({'before connection.close': ''});
  await realtime.close();
  await Future.delayed(Duration.zero);
  while (realtime.connection.state != ConnectionState.closed) {
    await Future.delayed(TestConstants.publishToHistoryDelay);
  }
  recordChannelState(); // channel: detached
  recordConnectionState(); // connection: closed
  reporter.reportLog({'after connection.close': ''});

  return {
    'connectionStates': connectionStates,
    'connectionStateChanges': connectionStateChanges,
    'filteredConnectionStateChanges': filteredConnectionStateChanges,
    'channelStates': channelStates,
    'channelStateChanges': channelStateChanges,
    'filteredChannelStateChanges': filteredChannelStateChanges,
  };
}
