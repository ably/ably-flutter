import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;

import '../provisioning.dart' as provisioning;
import 'mock_data.dart';

const String _ablyApiKey = 'ABLY_API_KEY';

class AblyService {
  static String defaultChannel = 'test-channel';
  ably.Rest? rest;
  ably.Realtime? realtime;
  String apiKey = const String.fromEnvironment(_ablyApiKey);
  final _subscriptions = <StreamSubscription>[];

  AblyService() {
    if (const bool.hasEnvironment(_ablyApiKey)) {
      throw Exception(
          'apiKey is ‘not defined, you should specify --dart-define=ABLY_API_KEY=your_api_key');
    }
  }

  initializeRestClient() async {
    rest = ably.Rest(options: await _createRestClientOptions());
    _publishMessagesUsingRestClient();
  }

  void releaseRestChannel() {
    rest?.channels.release(defaultChannel);
  }

  Future<void> initializeRealtimeClient() async {
    realtime = ably.Realtime(options: await _createRealtimeClientOptions());
    await realtime!.connect();
  }

  Future<void> enterRealtimeChannelPresence() async {
    await realtime!.channels
        .get(defaultChannel)
        .presence
        .enter(MockData.createMockPresenceData());
  }

  Future<void> leaveRealtimeChannelPresence() async {
    await realtime!.channels.get(defaultChannel).presence.leave();
  }

  Future<void> updateRealtimeChannelPresence() async {
    await realtime!.channels
        .get(defaultChannel)
        .presence
        // TODO why are we specifying a client Id here??
        .updateClient('flutter-example-app', MockData.createMockPresenceData());
  }

  Future<List<ably.PresenceMessage>> getRealtimeChannelPresence() async {
    return await realtime!.channels
        .get(defaultChannel)
        .presence
        .get(ably.RealtimePresenceParams());
  }

  Future<void> subscribeToRealtimeChannelPresence(
      void Function(ably.PresenceMessage) presenceMessageHandler) async {
    final channel = realtime!.channels.get(defaultChannel);
    channel.presence.subscribe().listen(presenceMessageHandler);
  }

  _publishMessagesUsingRestClient() async {
    assert(rest != null);
    const name = 'Hello';
    const dynamic data = 'Flutter';
    try {
      await Future.wait([
        rest!.channels.get(defaultChannel).publish(name: name, data: data),
        rest!.channels.get(defaultChannel).publish(name: name)
      ]);
      await rest!.channels.get(defaultChannel).publish(data: data);
      await rest!.channels.get(defaultChannel).publish();
      print('Messages published');
    } on ably.AblyException catch (e) {
      print(e.errorInfo);
    }
  }

  publishMessageUsingRestClient(Object data) async {
    await rest!.channels.get(defaultChannel).publish(name: 'Hello', data: data);
  }

  Future<void> subscribeToRealtimeConnectionStateChanges(
      void Function(ably.ConnectionStateChange event)? onStateChange) async {
    final connectionSubscription =
        realtime!.connection.on().listen((stateChange) async {
      print('${DateTime.now()}:'
          ' ConnectionStateChange event: ${stateChange.event}'
          '\nReason: ${stateChange.reason}');
    });
    _subscriptions.add(connectionSubscription);
  }

  subscribeToRealtimeChannelStateChanges(
      void Function(ably.ChannelStateChange event)? onStateChange) async {
    final channel = realtime!.channels.get(defaultChannel);
    final _channelStateChangeSubscription = channel.on().listen(onStateChange);
    _subscriptions.add(_channelStateChangeSubscription);
  }

  Future<ably.ClientOptions> _createRestClientOptions() async {
    return ably.ClientOptions()
          // .fromKey(_appKey)
          ..environment = 'sandbox'
          ..logLevel = ably.LogLevel.verbose
          ..logHandler = ({msg, exception}) {
            print('Custom logger :: $msg $exception');
          }
          ..tokenDetails = await provisioning.getTokenDetails(
            apiKey,
            'sandbox-',
          )
        /*..defaultTokenParams = ably.TokenParams(ttl: 20000)*/
        /*..authCallback = (params) async => ably.TokenRequest.fromMap(
            Map.castFrom<dynamic, dynamic, String, dynamic>(
              await provisioning.getTokenRequest(),
            ),
          )*/
        ;
  }

  Future<ably.ClientOptions> _createRealtimeClientOptions() async {
    return ably.ClientOptions.fromKey(apiKey)
      ..environment = 'sandbox'
      ..clientId = 'flutter-example-app'
      ..logLevel = ably.LogLevel.verbose
      ..autoConnect = false
      ..logHandler = ({msg, exception}) {
        print('Custom logger :: $msg $exception');
      };
  }

  void close() {
    // TODO close all subscriptions
    for (final s in _subscriptions) {
      s.cancel();
    }
    // TODO evaluate if this is actually needed.

    realtime?.close();
    realtime = null;
  }
}
