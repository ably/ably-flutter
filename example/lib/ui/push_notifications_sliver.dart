import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';

import 'four_mode_text_button.dart';

class PushNotificationsSliver extends StatefulWidget {
  final ably.Realtime? _realtime;

  const PushNotificationsSliver(this._realtime, {Key? key}) : super(key: key);

  @override
  _PushNotificationsSliverState createState() =>
      _PushNotificationsSliverState();
}

class _PushNotificationsSliverState extends State<PushNotificationsSliver> {
  bool _deviceActivationState = false;

  // TODO determine if device has been activated any time in the past
  String? deviceId;

  Widget instantiateRealtimeWarning() {
    if (widget._realtime == null) {
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
          FourModeActionButton(
              actionText: "Activate",
              opState: ,
              // disabled: widget._realtime == null,
              // isSuccessful: _deviceActivationState,
              onPressed: () async {
                print(widget._realtime);
                ably.DeviceDetails deviceDetails =
                    await widget._realtime!.push.activate();
                print(deviceDetails);
                setState(() {
                  _deviceActivationState = true;
                });
              }),
          FourModeActionButton(
              actionText: "Deactivate",
              disabled: _deviceActivationState || widget._realtime == null,
              onPressed: () {
                print(widget._realtime);
              }),
        ],
      ),
    );
  }
}
