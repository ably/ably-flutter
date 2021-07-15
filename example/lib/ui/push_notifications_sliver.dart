import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';

import '../op_state.dart';

class PushNotificationsSliver extends StatefulWidget {
  late final ably.AblyBase? _client;

  PushNotificationsSliver({ably.Realtime? realtime, ably.Rest? rest, Key? key})
      : super(key: key) {
    if (realtime != null) {
      _client = realtime;
    } else if (rest != null) {
      _client = rest;
    } else {
      _client = null;
    }
  }

  @override
  _PushNotificationsSliverState createState() =>
      _PushNotificationsSliverState();
}

class _PushNotificationsSliverState extends State<PushNotificationsSliver> {
  OpState _deviceActivationState = OpState.notStarted;

  @override
  void initState() {
    super.initState();
    // TODO determine if device has been activated any time in the past
      _deviceActivationState = OpState.notStarted;
  }

  String? deviceId;

  Widget instantiateRealtimeWarning() {
    if (widget._client == null) {
      return RichText(
          text: TextSpan(children: [
        TextSpan(
            text: "Warning: ",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.normal)),
        TextSpan(
            text: "instantiate an Ably realtime client.",
            style: TextStyle(color: Colors.black))
      ]));
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._client == null) {
      return Container(
          child: Text(
              "No client exists, create either a rest or realtime client."));
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Push Notifications',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          instantiateRealtimeWarning(),
          (deviceId != null)
              ? Text("Device is registered with \(deviceId)")
              : Text("Device is not registered"),
          TextButton(
              child: Text("Activate device"),
              // stage: _deviceActivationState,
              // disabled: widget._realtime == null,
              // isSuccessful: _deviceActivationState,
              onPressed: () async {
                ably.DeviceDetails deviceDetails =
                    await widget._client!.push.activate();
                print("Device details: $deviceDetails");
                setState(() {
                  _deviceActivationState = OpState.succeeded;
                });
              }),
          TextButton(
              child: Text("Deactivate device"),
              // stage: OpState.notStarted,
              onPressed: () {
                print(widget._client);
              }),
        ],
      ),
    );
  }
}
