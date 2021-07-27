import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ably_flutter/ably_flutter.dart' as ably;

import '../../constants.dart';
import '../../op_state.dart';

class PushNotificationsSubscriptionsSliver extends StatefulWidget {
  final ably.PushChannel? _pushChannel;
  final OpState _deviceActivationState;
  final String? deviceId;

  const PushNotificationsSubscriptionsSliver(
      this._pushChannel, this._deviceActivationState, this.deviceId,
      {Key? key})
      : super(key: key);

  @override
  _PushNotificationsSubscriptionsSliverState createState() =>
      _PushNotificationsSubscriptionsSliverState();
}

class _PushNotificationsSubscriptionsSliverState
    extends State<PushNotificationsSubscriptionsSliver> {
  bool get enablePublishButtons =>
      widget._deviceActivationState == OpState.succeeded &&
      widget._pushChannel != null;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Subscriptions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
                onPressed:
                    enablePublishButtons && widget.deviceId != null
                        ? () async {
                            ably.PaginatedResultInterface<
                                ably.PushChannelSubscription>? subscriptions;
                            if (widget._pushChannel != null) {
                              subscriptions = await widget._pushChannel!
                                  .listSubscriptions({
                                'channel': Constants.channelNameForPushNotifications,
                                'deviceId': widget.deviceId!
                              });
                              print('Subscriptions: $subscriptions');
                            }
                          }
                        : null,
                child: const Text('List subscriptions')),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                      onPressed: enablePublishButtons
                          ? () async {
                              await widget._pushChannel!.subscribeDevice();
                            }
                          : null,
                      child: const Text('Subscribe device')),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: enablePublishButtons
                        ? () async {
                            await widget._pushChannel!.unsubscribeDevice();
                          }
                        : null,
                    child: const Text('Unsubscribe device'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                      onPressed: enablePublishButtons
                          ? () async {
                              await widget._pushChannel!.subscribeClient();
                            }
                          : null,
                      child: const Text('Subscribe client')),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: enablePublishButtons
                          ? () async {
                              await widget._pushChannel!.unsubscribeClient();
                            }
                          : null,
                      child: const Text('Unsubscribe client')),
                )
              ],
            ),
          ],
        ),
      );
}
