import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/push_notification_service.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../op_state.dart';
import 'push_notifications_activation_sliver.dart';
import 'push_notifications_publishing_sliver.dart';
import 'push_notifications_subscriptions_sliver.dart';

class PushNotificationsSliver extends StatefulWidget {
  late PushNotificationService pushNotificationService;

  PushNotificationsSliver({ably.Realtime? realtime, ably.Rest? rest, Key? key})
      : super(key: key) {
    pushNotificationService =
        PushNotificationService(realtime: realtime, rest: rest);
  }

  @override
  _PushNotificationsSliverState createState() =>
      _PushNotificationsSliverState();
}

class _PushNotificationsSliverState extends State<PushNotificationsSliver> {
  OpState _deviceActivationState = OpState.notStarted;
  ably.LocalDevice? _localDevice;
  ably.PushChannel? _pushChannel;

  bool get _ablyClientIsPresent =>
      widget._realtime != null || widget._rest != null;

  @override
  void initState() {
    super.initState();
    // TODO determine if device has been activated any time in the past
    _deviceActivationState = OpState.notStarted;

    if (widget._realtime != null || widget._rest != null) {
      // TODO investigate why this slows us down
      _getChannels();
    }
  }

  void _getChannels() {
    if (widget._realtime != null) {
      widget._realtimeChannel = widget._realtime!.channels
          .get(Constants.channelNameForPushNotifications);
      _pushChannel = widget._realtimeChannel!.push;
    } else if (widget._rest != null) {
      widget._restChannel =
          widget._rest!.channels.get(Constants.channelNameForPushNotifications);
      _pushChannel = widget._restChannel!.push;
    }

    throw Exception(
        'No Ably client exists, cannot get rest/ realtime channels or push channels.');
  }

  Widget buildCreateAblyClientText() {
    if (!_ablyClientIsPresent) {
      return RichText(
          text: const TextSpan(children: [
        TextSpan(
            text: 'Warning: ',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        TextSpan(
            text: 'Create an Ably realtime or rest client above',
            style: TextStyle(color: Colors.black))
      ]));
    }

    return const SizedBox.shrink();
  }

  void updateDeviceActivationState(OpState newState) {
    setState(() {
      _deviceActivationState = newState;
    });
  }

  void setLocalDevice(ably.LocalDevice? newLocalDevice) {
    setState(() {
      _localDevice = newLocalDevice;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Push Notifications',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            buildCreateAblyClientText(),
            PushNotificationsActivationSliver(widget._realtime, widget._rest,
                _localDevice, updateDeviceActivationState, setLocalDevice),
            PushNotificationsSubscriptionsSliver(
                _pushChannel, _deviceActivationState, _localDevice?.id),
            PushNotificationsPublishingSliver(
                _pushChannel,
                _deviceActivationState,
                widget._realtimeChannel,
                widget._restChannel),
            // TODO Implement Push Admin API and use the following:
            // PushNotificationsAdminPublishingSliver(
            //   realtimeChannel: _realtimeChannel,
            //   restChannel: _restChannel,
            //   pushChannel: _pushChannel,
            //   deviceActivationState: _deviceActivationState,
            // ),
          ],
        ),
      );
}
