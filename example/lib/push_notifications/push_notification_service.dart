import 'dart:async';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:rxdart/rxdart.dart';

import '../constants.dart';
import 'android_push_notification_configuration.dart';
import 'push_notification_message_examples.dart';

class PushNotificationService {
  final _androidPushNotificationConfiguration =
      AndroidPushNotificationConfiguration();
  ably.Realtime? realtime;
  ably.Rest? rest;
  ably.RealtimeChannelInterface? _realtimeChannel;
  ably.RealtimeChannelInterface? _pushLogMetachannel;
  ably.RestChannelInterface? _restChannel;
  late ably.PushChannel? _pushChannel;

  final BehaviorSubject<
          ably.PaginatedResultInterface<ably.PushChannelSubscription>>
      _pushChannelDeviceSubscriptionsSubject = BehaviorSubject<
          ably.PaginatedResultInterface<ably.PushChannelSubscription>>();

  ValueStream<ably.PaginatedResultInterface<ably.PushChannelSubscription>>
      get pushChannelDeviceSubscriptionsStream =>
          _pushChannelDeviceSubscriptionsSubject.stream;

  final BehaviorSubject<
          ably.PaginatedResultInterface<ably.PushChannelSubscription>>
      _pushChannelClientSubscriptionsSubject = BehaviorSubject<
          ably.PaginatedResultInterface<ably.PushChannelSubscription>>();

  ValueStream<ably.PaginatedResultInterface<ably.PushChannelSubscription>>
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

  void setRealtimeClient(ably.Realtime realtime) {
    this.realtime = realtime;
    _getChannels();
    getDevice();
    if (Platform.isIOS) {
      updateNotificationSettings();
    }
  }

  Future<void> ensureRealtimeClientConnected() async {
    if (realtime?.connection.state != ably.ConnectionState.connected) {
      await realtime!.connect();
    }
  }

  void setRestClient(ably.Rest rest) {
    this.rest = rest;
    _getChannels();
    if (Platform.isIOS) {
      updateNotificationSettings();
    }
  }

  /// Only valid on iOS
  Future<void> requestNotificationPermission({bool provisional = false}) async {
    if (realtime != null) {
      final granted =
          await realtime!.push.requestPermission(provisional: provisional);
      _userNotificationPermissionGrantedSubject.add(granted);
    } else if (rest != null) {
      final granted =
          await rest!.push.requestPermission(provisional: provisional);
      _userNotificationPermissionGrantedSubject.add(granted);
    } else {
      throw Exception('No ably client available');
    }
    await updateNotificationSettings();
  }

  /// Only valid on iOS
  Future<void> updateNotificationSettings() async {
    if (realtime != null) {
      final settings = await realtime!.push.getNotificationSettings();
      _notificationSettingsSubject.add(settings);
    } else if (rest != null) {
      _notificationSettingsSubject
          .add(await rest!.push.getNotificationSettings());
    } else {
      throw Exception('No ably client available');
    }
  }

  Future<void> activateDevice() => getPushFromAblyClient().activate();

  Future<void> deactivateDevice() => getPushFromAblyClient().deactivate();

  Future<void> getDevice() async {
    if (realtime != null) {
      final localDevice = await realtime!.device();
      _localDeviceSubject.add(localDevice);
    } else {
      final localDevice = await rest!.device();
      _localDeviceSubject.add(localDevice);
    }
  }

  ably.Push getPushFromAblyClient() {
    if (realtime != null) {
      return realtime!.push;
    } else if (rest != null) {
      return rest!.push;
    } else {
      throw Exception('No ably client available');
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
      print('Message clientId: ${message?.clientId}');
      print('Message extras: ${message?.extras}');
    });
    return stream;
  }

  StreamSubscription<ably.Message?>? _realtimeChannelStreamSubscription;

  Future<Stream<ably.Message?>> subscribeToPushLogMetachannel() async {
    await ensureRealtimeClientConnected();
    final stream = _pushLogMetachannel!.subscribe();
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
    if (_realtimeChannel != null) {
      await _realtimeChannel!.publish(
          message: PushNotificationMessageExamples.pushNotificationMessage);
    } else if (_restChannel != null) {
      await _restChannel!.publish(
          message: PushNotificationMessageExamples.pushNotificationMessage);
    }
  }

  Future<void> publishDataMessageToChannel() async {
    await ensureRealtimeClientConnected();
    if (_realtimeChannel != null) {
      await _realtimeChannel!
          .publish(message: PushNotificationMessageExamples.pushDataMessage);
    } else if (_restChannel != null) {
      await _restChannel!
          .publish(message: PushNotificationMessageExamples.pushDataMessage);
    }
  }

  Future<void> publishDataNotificationMessageToChannel() async {
    await ensureRealtimeClientConnected();
    if (_realtimeChannel != null) {
      await _realtimeChannel!.publish(
          message: PushNotificationMessageExamples.pushDataNotificationMessage);
    } else if (_restChannel != null) {
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
    if (realtime != null) {
      _realtimeChannel =
          realtime!.channels.get(Constants.channelNameForPushNotifications);
      _pushChannel = _realtimeChannel!.push;
      _pushLogMetachannel =
          realtime!.channels.get(Constants.pushMetaChannelName);
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

  /// Unfortunately ably-cocoa and ably-java are inconsistent here.
  /// Ably-java will list all subscriptions (clientId and deviceId), where as
  /// ably-cocoa will only give the one you specify in params.
  /// This behavior is the same for [listSubscriptionsWithDeviceId]
  Future<ably.PaginatedResultInterface<ably.PushChannelSubscription>>
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

  Future<ably.PaginatedResultInterface<ably.PushChannelSubscription>>
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
