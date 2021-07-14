import 'package:flutter/widgets.dart';

import '../op_state.dart';
import '../provisioning.dart' as provisioning;

class AblyAccountSliver extends StatefulWidget {
  const AblyAccountSliver({Key? key}) : super(key: key);

  @override
  _AblyAccountSliverState createState() => _AblyAccountSliverState();
}

class _AblyAccountSliverState extends State<AblyAccountSliver> {
  OpState _provisioningState = OpState.notStarted;

  Future<void> provisionAbly() async {
    setState(() {
      _provisioningState = OpState.inProgress;
    });

    provisioning.AppKey appKey;
    try {
      appKey = await provisioning.provision('sandbox-');
      print('App key acquired! `$appKey`');
    } on Exception catch (error) {
      print('Error provisioning Ably: $error');
      setState(() {
        _provisioningState = OpState.failed;
      });
      return;
    }

    setState(() {
      _appKey = appKey;
      _provisioningState = OpState.succeeded;
    });
  }

  Widget provisionButton() => button(
      _provisioningState,
      provisionAbly,
      '1. Provision Temporary Ably Account',
      'Provisioning',
      'Temporary Ably Account Provisioned');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Ably Account',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
            'You can either (1) create a temporary Ably account or (2) enter your own Ably API key\n'),
        Text(
          'App Key:'
              ' ${_appKey?.toString() ?? 'Ably not provisioned yet.'}',
        ),
        // TODO add way to specify API key during build time/ in code
        provisionButton(),
        TextField(
            decoration: InputDecoration(labelText: "Ably API key")
        ),
        FourModeTextButton(actionText: "2. Use Ably API key", onPressed: () {
        }),
      ],
    );
  }
}
