import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../op_state.dart';

class PushNotificationsActivationSliver extends StatelessWidget {
  final ably.LocalDevice? _localDevice;
  final ably.Realtime? _realtime;
  final ably.Rest? _rest;
  final void Function(OpState newState) setDeviceActivationState;
  final void Function(ably.LocalDevice? newDeviceId) setLocalDevice;

  const PushNotificationsActivationSliver(this._realtime, this._rest,
      this._localDevice, this.setDeviceActivationState, this.setLocalDevice,
      {Key? key})
      : super(key: key);

  bool get _ablyClientIsPresent => _realtime != null || _rest != null;

  Future<void> activateDevice() async {
    if (_realtime != null) {
      await _realtime!.push.activate();
      print('Push: ${_realtime?.push}');
    } else {
      await _rest!.push.activate();
      print('Push: ${_rest?.push}');
    }
    setDeviceActivationState(OpState.succeeded);
  }

  Widget buildLocalDeviceInformation() {
    if (_localDevice != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Device is registered'),
          Text('deviceId: ${_localDevice!.id}'),
          Text('clientId: ${_localDevice!.clientId}'),
          Text('platform: ${_localDevice!.platform}'),
          Text('formFactor: ${_localDevice!.formFactor}'),
          Text('metadata: ${_localDevice!.metadata}'),
          Text('DevicePushDetails state: ${_localDevice!.push.state}'),
          Text('DevicePushDetails recipient: ${_localDevice!.push.recipient}'),
        ],
      );
    } else {
      return RichText(
          text: const TextSpan(children: [
        TextSpan(
            text: 'Warning: ',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        TextSpan(
            text: 'Device is not activated/ registered.',
            style: TextStyle(color: Colors.black))
      ]));
    }
  }

  Future<void> getDevice() async {
    if (_realtime != null) {
      final localDevice = await _realtime!.device();
      if (localDevice != null) {
        setLocalDevice(localDevice);
      }
    } else {
      final localDevice = await _rest!.device();
      if (localDevice != null) {
        setLocalDevice(localDevice);
      }
    }
    setDeviceActivationState(OpState.succeeded);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Activation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                    onPressed: (!_ablyClientIsPresent)
                        ? null
                        : () async {
                            await activateDevice();
                            // Just getting the device details immediately.
                            await getDevice();
                          },
                    child: const Text('Activate device')),
              ),
              Expanded(
                child: TextButton(
                    onPressed: (!_ablyClientIsPresent)
                        ? null
                        : () async {
                            if (_realtime != null) {
                              await _realtime!.push.deactivate();
                              print('Push: ${_realtime?.push}');
                            } else {
                              await _rest!.push.deactivate();
                              print('Push: ${_rest?.push}');
                            }
                            setLocalDevice(null);
                            setDeviceActivationState(OpState.notStarted);
                          },
                    child: const Text('Deactivate device')),
              ),
            ],
          ),
          const Text(
            'Local Device information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          buildLocalDeviceInformation(),
        ],
      );
}
