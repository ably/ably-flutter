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

  Widget buildMissingAblyClientWarningText() {
    if (widget._client == null) {
      return RichText(
          text: TextSpan(children: [
        TextSpan(
            text: "Warning: ",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        TextSpan(
            text: "Create a realtime or rest client",
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
          buildMissingAblyClientWarningText(),
          (deviceId != null)
              ? Text("Device is registered with \(deviceId)")
              : Text("Device is not registered"),
          TextButton(
              child: Text("Activate device"),
              // stage: _deviceActivationState,
              // disabled: widget._realtime == null,
              // isSuccessful: _deviceActivationState,
              onPressed: (widget._client == null)
                  ? null
                  : () async {
                      await widget._client!.push.activate();
                      print("Push: ${widget._client?.push}");
                      setState(() {
                        _deviceActivationState = OpState.succeeded;
                      });
                    }),
          TextButton(
              child: Text("Deactivate device"),
              // stage: OpState.notStarted,
              onPressed: (widget._client == null)
                  ? null
                  : () async {
                      print(widget._client);
                    }),
          TextButton(
            child: Text("Subscribe device"),
            onPressed: () {},
          ),
          TextButton(child: Text("Subscribe client"), onPressed: () {}),
          TextButton(
            child: Text("Unsubscribe device"),
            onPressed: () {},
          ),
          TextButton(child: Text("Unsubscribe client"), onPressed: () {}),
          TextButton(
            child: Text("Publish to channel"),
            onPressed: () {},
          ),
          TextButton(child: Text("Publish to client"), onPressed: () {}),
          TextButton(child: Text("List subscriptions"), onPressed: () {}),
        ],
      ),
    );
  }
}
