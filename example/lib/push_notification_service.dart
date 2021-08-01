import 'dart:async';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:rxdart/rxdart.dart';

import 'constants.dart';
import 'op_state.dart';

class PushNotificationService {
  late final ably.Realtime? realtime;
  late final ably.Rest? rest;
  ably.RealtimeChannelInterface? _realtimeChannel;
  StreamSubscription<ably.Message?>? _realtimeChannelStreamSubscription;
  ably.RestChannelInterface? _restChannel;
  late ably.PushChannel? _pushChannel;

  final BehaviorSubject<
          ably.PaginatedResultInterface<ably.PushChannelSubscription>>
      _pushChannelSubscriptionSubject = BehaviorSubject<
          ably.PaginatedResultInterface<ably.PushChannelSubscription>>();

  ValueStream<ably.PaginatedResultInterface<ably.PushChannelSubscription>>
      get pushChannelSubscriptionStream =>
          _pushChannelSubscriptionSubject.stream;

  ably.PaginatedResultInterface<ably.PushChannelSubscription>
      get _pushChannelSubscription => _pushChannelSubscriptionSubject.value;

  final BehaviorSubject<OpState> _deviceActivationStateSubject =
      BehaviorSubject<OpState>.seeded(OpState.notStarted);

  ValueStream<OpState> get deviceActivationStateStream =>
      _deviceActivationStateSubject.stream;

  final BehaviorSubject<bool> _hasPushChannelSubject =
      BehaviorSubject<bool>.seeded(false);

  ValueStream<bool> get hasPushChannelStream => _hasPushChannelSubject.stream;

  bool get hasPushChannel => _hasPushChannelSubject.value;

  final BehaviorSubject<ably.LocalDevice?> _localDeviceSubject =
      BehaviorSubject.seeded(null);
  late final ValueStream<ably.LocalDevice?> localDeviceStream =
      _localDeviceSubject.stream;

  ably.LocalDevice? get localDevice => localDeviceStream.value;

  void setRealtimeClient(ably.Realtime realtime) {
    this.realtime = realtime;
    _getChannels();
  }

  Future<void> ensureRealtimeClientConnected() async {
    if (realtime?.connection.state != ably.ConnectionState.connected) {
      await realtime!.connect();
    }
  }

  void setRestClient(ably.Rest rest) {
    this.rest = rest;
    _getChannels();
  }

  Future<void> activateDevice() async {
    if (realtime != null) {
      await realtime!.push.activate();
      print('Push: ${realtime!.push}');
    } else if (rest != null) {
      await rest!.push.activate();
      print('Push: ${rest!.push}');
    } else {
      throw Exception('No ably client available');
    }
    _deviceActivationStateSubject.add(OpState.succeeded);
  }

  Future<void> deactivateDevice() async {
    if (realtime != null) {
      await realtime!.push.deactivate();
      print('Push: ${realtime!.push}');
    } else {
      await rest!.push.deactivate();
      print('Push: ${rest!.push}');
    }
    _localDeviceSubject.add(null);
    _deviceActivationStateSubject.add(OpState.notStarted);
  }

  Future<void> getDevice() async {
    if (realtime != null) {
      final localDevice = await realtime!.device();
      _localDeviceSubject.add(localDevice);
    } else {
      final localDevice = await rest!.device();
      _localDeviceSubject.add(localDevice);
    }
    _deviceActivationStateSubject.add(OpState.succeeded);
  }

  /// Subscribes to the channel (not the push channel) which has a Push channel
  /// rule. This allows the device to receive push notifications when
  /// messages contain a push notification payload.
  ///
  /// See Channel-based broadcasting for more information
  /// https://ably.com/documentation/general/push/publish#channel-broadcast
  Future<Stream<ably.Message?>> subscribeToChannelWithPushChannelRule() async {
    await _realtimeChannelStreamSubscription?.cancel();
    await ensureRealtimeClientConnected();
    final stream = _realtimeChannel!.subscribe();
    _realtimeChannelStreamSubscription = stream.listen((message) {
      print('Message clientId: ${message?.clientId}');
      print('Message extras: ${message?.extras}');
    });
    return stream;
  }

  Future<void> unsubscribeToChannelWithPushChannelRule() async {
    await _realtimeChannelStreamSubscription?.cancel();
  }

  final ably.Message _pushMessage = ably.Message(
      data: 'Some data',
      extras: const ably.MessageExtras({
        'push': {
          'notification': {
            'title': 'Hello from Ably!',
            'body': 'Example push notification from Ably.'
          },
          'data': {'foo': 'bar', 'baz': 'quz'}
        },
      }));

  Future<void> publishToChannel() async {
    await ensureRealtimeClientConnected();
    if (_realtimeChannel != null) {
      _realtimeChannel!.publish(message: _pushMessage);
    } else if (_restChannel != null) {
      _restChannel!.publish(message: _pushMessage);
    }
  }

  void close() {
    _deviceActivationStateSubject.close();
    _hasPushChannelSubject.close();
    _localDeviceSubject.close();
    _realtimeChannelStreamSubscription?.cancel();
    _realtimeChannelStreamSubscription = null;
  }

  void _getChannels() {
    _hasPushChannelSubject.add(false);
    if (realtime != null) {
      _realtimeChannel =
          realtime!.channels.get(Constants.channelNameForPushNotifications);
      _pushChannel = _realtimeChannel!.push;
      _hasPushChannelSubject.add(true);
    } else if (rest != null) {
      _restChannel =
          rest!.channels.get(Constants.channelNameForPushNotifications);
      _pushChannel = _restChannel!.push;
      _hasPushChannelSubject.add(true);
    } else {
      throw Exception(
          'No Ably client exists, cannot get rest/ realtime channels or push channels.');
    }
  }

  Future<ably.PaginatedResultInterface<ably.PushChannelSubscription>>
      listSubscriptions() async {
    await getDevice();
    final deviceId = localDevice?.id;
    if (Platform.isAndroid) {
      if (deviceId == null) {
        throw Exception(
            'Device ID was null, but it needs to be specified on Android.');
      }

    }
    final subscriptions = await _pushChannel!.listSubscriptions({
      'channel': Constants.channelNameForPushNotifications,
      'deviceId': deviceId!,
      // 'clientId': "put_your_client_id_here",
    });
      _pushChannelSubscriptionSubject.add(subscriptions);
      return subscriptions;
  }

  Future<void> subscribeClient() async {
    await _pushChannel!.subscribeClient();
  }

  Future<void> unsubscribeClient() async {
    await _pushChannel!.unsubscribeClient();
  }

  Future<void> subscribeDevice() async {
    await _pushChannel!.subscribeDevice();
  }

  Future<void> unsubscribeDevice() async {
    await _pushChannel!.unsubscribeDevice();
  }
}
