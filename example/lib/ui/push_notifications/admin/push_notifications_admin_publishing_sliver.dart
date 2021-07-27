import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../op_state.dart';

class PushNotificationsAdminPublishingSliver extends StatelessWidget {
  final ably.RealtimeChannelInterface? realtimeChannel;
  final ably.RestChannelInterface? restChannel;
  final ably.PushChannel? pushChannel;
  final OpState? deviceActivationState;

  const PushNotificationsAdminPublishingSliver({
    this.realtimeChannel,
    this.restChannel,
    this.pushChannel,
    this.deviceActivationState,
    Key? key,
  }) : super(key: key);

  bool get enablePublishButtons =>
      deviceActivationState == OpState.succeeded && pushChannel != null;

  Widget buildNativePushNotificationsButton(BuildContext context) {
    if (Platform.isAndroid) {
      return TextButton(
          onPressed: enablePublishButtons
              ? publishToFCMRegistrationToken
              : null,
          child: const Text('Publish to FCM registration token'));
    } else if (Platform.isIOS) {
      return TextButton(
          onPressed: enablePublishButtons
              ? publishToAPNsDeviceToken
              : null,
          child: const Text('Publish to APNs deviceToken'));
    } else {
      return TextButton(
          onPressed: null,
          child: Text('Platform ${Theme.of(context).platform} not supported'));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextButton(
              onPressed: enablePublishButtons
                  ? publishToClientId
                  : null,
              child: const Text('Publish to clientId')),
          TextButton(
              onPressed: enablePublishButtons
                  ? publishToDeviceId
                  : null,
              child: const Text('Publish to deviceId')),
          buildNativePushNotificationsButton(context),
        ],
      );

  // TODO Publish using Push Admin api
  void publishToDeviceId() {}

  void publishToClientId() {}

  publishToAPNsDeviceToken() {}

  void publishToFCMRegistrationToken() {}
}
