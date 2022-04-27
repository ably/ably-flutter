import 'dart:async';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/push_notifications/android_push_notification_configuration.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_message_examples.dart';
import 'package:rxdart/rxdart.dart';

class PushNotificationService {
  final bool useRealtimeClient;
  final ably.Realtime _realtime;
  final ably.Rest _rest;
  late ably.RealtimeChannel? _realtimeChannel;
  late ably.RealtimeChannel? _pushLogMetaChannel;
  late ably.RestChannel? _restChannel;
  late ably.PushChannel? _pushChannel;

  PushNotificationService(
    this._realtime,
    this._rest, {
    this.useRealtimeClient = true,
  }) {
    _getChannels();
    getDevice();
    if (Platform.isIOS) {
      updateNotificationSettings();
    }
    AndroidPushNotificationConfiguration();
  }

  final BehaviorSubject<ably.PaginatedResult<ably.PushChannelSubscription>>
      _pushChannelDeviceSubscriptionsSubject =
      BehaviorSubject<ably.PaginatedResult<ably.PushChannelSubscription>>();

  ValueStream<ably.PaginatedResult<ably.PushChannelSubscription>>
      get pushChannelDeviceSubscriptionsStream =>
          _pushChannelDeviceSubscriptionsSubject.stream;

  final BehaviorSubject<ably.PaginatedResult<ably.PushChannelSubscription>>
      _pushChannelClientSubscriptionsSubject =
      BehaviorSubject<ably.PaginatedResult<ably.PushChannelSubscription>>();

  ValueStream<ably.PaginatedResult<ably.PushChannelSubscription>>
      get pushChannelClientSubscriptionsStream =>
          _pushChannelClientSubscriptionsSubject.stream;

  final BehaviorSubject<bool> _hasPushChannelSubject =
      BehaviorSubject<bool>.seeded(false);

  ValueStream<bool> get hasPushChannelStream => _hasPushChannelSubject.stream;

  final BehaviorSubject<ably.LocalDevice?> _localDeviceSubject =
      BehaviorSubject.seeded(null);
  late final ValueStream<ably.LocalDevice?> localDeviceStream =
      _localDeviceSubject.stream;

  final BehaviorSubject<bool> _userNotificationPermissionGrantedSubject =
      BehaviorSubject();
  late final ValueStream<bool> userNotificationPermissionGrantedStream =
      _userNotificationPermissionGrantedSubject.stream;

  final BehaviorSubject<ably.UNNotificationSettings>
      _notificationSettingsSubject = BehaviorSubject();
  late final ValueStream<ably.UNNotificationSettings>
      notificationSettingsStream = _notificationSettingsSubject.stream;

  Future<void> ensureRealtimeClientConnected() async {
    if (_realtime.connection.state != ably.ConnectionState.connected) {
      await _realtime.connect();
    }
  }

  /// Only valid on iOS
  Future<void> requestNotificationPermission(
      {bool provisional = false,
      bool providesAppNotificationSettings = true}) async {
    if (useRealtimeClient) {
      final granted = await _realtime.push.requestPermission(
          provisional: provisional,
          providesAppNotificationSettings: providesAppNotificationSettings);
      _userNotificationPermissionGrantedSubject.add(granted);
    } else {
      final granted = await _rest.push.requestPermission(
          provisional: provisional,
          providesAppNotificationSettings: providesAppNotificationSettings);
      _userNotificationPermissionGrantedSubject.add(granted);
    }
    await updateNotificationSettings();
  }

  /// Only valid on iOS
  Future<void> updateNotificationSettings() async {
    if (useRealtimeClient) {
      final settings = await _realtime.push.getNotificationSettings();
      _notificationSettingsSubject.add(settings);
    } else {
      _notificationSettingsSubject
          .add(await _rest.push.getNotificationSettings());
    }
  }

  Future<void> activateDevice() => getPushFromAblyClient().activate();

  Future<void> deactivateDevice() => getPushFromAblyClient().deactivate();

  Future<void> resetActivation() => getPushFromAblyClient().reset();

  Future<void> getDevice() async {
    if (useRealtimeClient) {
      final localDevice = await _realtime.device();
      _localDeviceSubject.add(localDevice);
    } else {
      final localDevice = await _rest.device();
      _localDeviceSubject.add(localDevice);
    }
  }

  ably.Push getPushFromAblyClient() {
    if (useRealtimeClient) {
      return _realtime.push;
    } else {
      return _rest.push;
    }
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
      print('Message clientId: ${message.clientId}');
      print('Message extras: ${message.extras}');
    });
    return stream;
  }

  StreamSubscription<ably.Message?>? _realtimeChannelStreamSubscription;

  Future<Stream<ably.Message?>> subscribeToPushLogMetachannel() async {
    await ensureRealtimeClientConnected();
    final stream = _pushLogMetaChannel!.subscribe();
    _pushLogMetaChannelSubscription = stream.listen((message) {
      print('MetaChannel message');
      print(message);
    });
    return stream;
  }

  StreamSubscription<ably.Message?>? _pushLogMetaChannelSubscription;

  Future<void> unsubscribeToChannelWithPushChannelRule() async {
    await _realtimeChannelStreamSubscription?.cancel();
  }

  Future<void> publishNotificationMessageToChannel() async {
    await ensureRealtimeClientConnected();
    if (useRealtimeClient) {
      await _realtimeChannel!.publish(
          message: PushNotificationMessageExamples.pushNotificationMessage);
    } else {
      await _restChannel!.publish(
          message: PushNotificationMessageExamples.pushNotificationMessage);
    }
  }

  Future<void> publishDataMessageToChannel() async {
    await ensureRealtimeClientConnected();
    if (useRealtimeClient) {
      await _realtimeChannel!
          .publish(message: PushNotificationMessageExamples.pushDataMessage);
    } else {
      await _restChannel!
          .publish(message: PushNotificationMessageExamples.pushDataMessage);
    }
  }

  Future<void> publishDataNotificationMessageToChannel() async {
    await ensureRealtimeClientConnected();
    if (useRealtimeClient) {
      await _realtimeChannel!.publish(
          message: PushNotificationMessageExamples.pushDataNotificationMessage);
    } else {
      await _restChannel!.publish(
          message: PushNotificationMessageExamples.pushDataNotificationMessage);
    }
  }

  void close() {
    _hasPushChannelSubject.close();
    _localDeviceSubject.close();
    _userNotificationPermissionGrantedSubject.close();
    _realtimeChannelStreamSubscription?.cancel();
    _realtimeChannelStreamSubscription = null;
    _pushLogMetaChannelSubscription?.cancel();
    _pushLogMetaChannelSubscription = null;
  }

  void _getChannels() {
    _hasPushChannelSubject.add(false);
    if (useRealtimeClient) {
      _realtimeChannel =
          _realtime.channels.get(Constants.channelNameForPushNotifications);
      _pushChannel = _realtimeChannel!.push;
      _pushLogMetaChannel =
          _realtime.channels.get(Constants.pushMetaChannelName);
      _hasPushChannelSubject.add(true);
    } else {
      _restChannel =
          _rest.channels.get(Constants.channelNameForPushNotifications);
      _pushChannel = _restChannel!.push;
      _hasPushChannelSubject.add(true);
    }
  }

  /// Unfortunately ably-cocoa and ably-java are inconsistent here.
  /// Ably-java will list all subscriptions (clientId and deviceId), where as
  /// ably-cocoa will only give the one you specify in params.
  /// This behavior is the same for [listSubscriptionsWithDeviceId]
  Future<ably.PaginatedResult<ably.PushChannelSubscription>>
      listSubscriptionsWithClientId() async {
    await getDevice();
    final subscriptions = await _pushChannel!.listSubscriptions({
      'clientId': localDeviceStream.value!.clientId!,
      // Optionally, limit the size of the paginated response.
      // 'limit': '1'
    });
    _pushChannelClientSubscriptionsSubject.add(subscriptions);
    return subscriptions;
  }

  Future<ably.PaginatedResult<ably.PushChannelSubscription>>
      listSubscriptionsWithDeviceId() async {
    await getDevice();
    final subscriptions = await _pushChannel!.listSubscriptions({
      'deviceId': localDeviceStream.value!.id!,
      // Optionally, limit the size of the paginated response.
      // 'limit': '1'
    });
    _pushChannelDeviceSubscriptionsSubject.add(subscriptions);
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
