import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';

import '../op_state.dart';

const String _pushChannel = 'push:test-push-channel';

class PushNotificationsSliver extends StatefulWidget {
  late final ably.Realtime? _realtime;
  late final ably.Rest? _rest;
  late bool _useRealtimeClient;

  PushNotificationsSliver({ably.Realtime? realtime, ably.Rest? rest, Key? key})
      : super(key: key) {
    _realtime = realtime;
    _rest = rest;

    if (_realtime != null) {
      _useRealtimeClient = true;
    } else {
      _useRealtimeClient = false;
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

  bool get _ablyClientIsPresent =>
      widget._realtime != null || widget._rest != null;

  Widget buildMissingAblyClientWarningText() {
    if (!_ablyClientIsPresent) {
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
            child: Text("Get device"), onPressed: (!_ablyClientIsPresent)
              ? null
              : () async {
            if (widget._realtime != null) {
              ably.LocalDevice localDevice = await widget._realtime!.device();
              print("Local device is: ${localDevice}");
              print("Push: ${widget._realtime?.push}");
            } else {
              await widget._rest!.device();
              print("Push: ${widget._rest?.push}");
            }
            setState(() {
              _deviceActivationState = OpState.succeeded;
            });
          },),
          TextButton(
              child: Text("Activate device"),
              // stage: _deviceActivationState,
              // disabled: widget._realtime == null,
              // isSuccessful: _deviceActivationState,
              onPressed: (!_ablyClientIsPresent)
                  ? null
                  : () async {
                      if (widget._realtime != null) {
                        await widget._realtime!.push.activate();
                        print("Push: ${widget._realtime?.push}");
                      } else {
                        await widget._rest!.push.activate();
                        print("Push: ${widget._rest?.push}");
                      }
                      setState(() {
                        _deviceActivationState = OpState.succeeded;
                      });
                    }),
          TextButton(
              child: Text("Deactivate device"),
              // stage: OpState.notStarted,
              onPressed: (!_ablyClientIsPresent)
                  ? null
                  : () async {
                      if (widget._realtime != null) {
                        await widget._realtime!.push.deactivate();
                        print("Push: ${widget._realtime?.push}");
                      } else {
                        await widget._rest!.push.deactivate();
                        print("Push: ${widget._rest?.push}");
                      }
                    }),
          TextButton(
              child: Text("Subscribe device"),
              onPressed: (!_ablyClientIsPresent)
                  ? null
                  : () async {
                      if (widget._realtime != null) {
                        widget._realtime!.channels
                            .get(_pushChannel)
                            .push
                            .subscribeDevice();
                      } else {
                        widget._rest!.channels
                            .get(_pushChannel)
                            .push
                            .subscribeDevice();
                      }
                    }),
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
