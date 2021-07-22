import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';

import '../op_state.dart';

const String _pushChannelName = 'push:test-push-channel';

class PushNotificationsSliver extends StatefulWidget {
  late final ably.Realtime? _realtime;
  late final ably.Rest? _rest;

  PushNotificationsSliver({ably.Realtime? realtime, ably.Rest? rest, Key? key})
      : super(key: key) {
    _realtime = realtime;
    _rest = rest;
  }

  @override
  _PushNotificationsSliverState createState() =>
      _PushNotificationsSliverState();
}

class _PushNotificationsSliverState extends State<PushNotificationsSliver> {
  OpState _deviceActivationState = OpState.notStarted;

  ably.PushChannel? _pushChannel;

  @override
  void initState() {
    super.initState();
    // TODO determine if device has been activated any time in the past
    _deviceActivationState = OpState.notStarted;

    if (widget._realtime != null || widget._rest != null) {
      _pushChannel = _getPushChannel();
    }
  }

  ably.PushChannel _getPushChannel() {
    if (widget._realtime != null) {
      return widget._realtime!.channels.get(_pushChannelName).push;
    } else if (widget._rest != null) {
      return widget._rest!.channels.get(_pushChannelName).push;
    }

    throw Exception(
        "No Ably client exists. Improve this error message though?");
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
  Widget build(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Push Notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            buildMissingAblyClientWarningText(),
            if (deviceId != null)
              const Text('Device is registered with \(deviceId)')
            else
              const Text('Device is not registered'),
            TextButton(
              onPressed: (!_ablyClientIsPresent)
                  ? null
                  : () async {
                      if (widget._realtime != null) {
                        ably.LocalDevice localDevice =
                            await widget._realtime!.device();
                        print("Local device is: ${localDevice}");
                        print('Push: ${widget._realtime?.push}');
                      } else {
                        await widget._rest!.device();
                        print('Push: ${widget._rest?.push}');
                      }
                      setState(() {
                        _deviceActivationState = OpState.succeeded;
                      });
                    },
              child: Text("Get device"),
            ),
            TextButton(
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
                      },
                child: Text("Activate device")),
            TextButton(
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
                      },
                child: Text("Deactivate device")),
            TextButton(
                onPressed: (!_ablyClientIsPresent)
                    ? null
                    : () async {
                        await _pushChannel!.subscribeDevice();
                      },
                child: const Text('Subscribe device')),
            TextButton(onPressed: () {}, child: Text("Subscribe client")),
            TextButton(
              onPressed: () {},
              child: const Text('Unsubscribe device'),
            ),
            TextButton(onPressed: () {}, child: Text("Unsubscribe client")),
            TextButton(
              onPressed: () {},
              child: const Text('Publish to channel'),
            ),
            TextButton(
                onPressed: () {}, child: const Text('Publish to client')),
            TextButton(
                onPressed: _ablyClientIsPresent
                    ? () async {
                        ably.PaginatedResultInterface<
                            ably.PushChannelSubscription>? subscriptions;
                        if (_pushChannel != null) {
                          subscriptions =
                              await _pushChannel!.listSubscriptions({"channel": _pushChannelName});
                          print('Subscriptions: ${subscriptions}');
                        }
                      }
                    : null,
                child: const Text('List subscriptions')),
          ],
        ),
      );
}
