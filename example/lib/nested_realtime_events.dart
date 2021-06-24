// NOTE: this file is not being used anywhere, yet
// this could serve as a reference for writing nested listeners

import 'dart:async';

import 'package:ably_flutter/ably_flutter.dart' as ably;

/// This method is a demonstration on how to use multiple listeners
/// with realtime connection state change listeners as an example
///
/// It aims to demonstrate the working of nested listeners
/// and cancelling listeners on specific events
void listenRealtimeConnection(ably.Realtime realtime) {
  //One can listen from multiple listeners on the same event,
  // and must cancel each subscription one by one
  //RETAINING LISTENER - α
  realtime.connection.on().listen((stateChange) {
    print('RETAINING LISTENER α :: Change event arrived!: ${stateChange.event}'
        '\nReason: ${stateChange.reason}');
  });

  //DISPOSE ON CONNECTED
  final stream = realtime.connection.on();
  late StreamSubscription omegaSubscription;
  omegaSubscription = stream.listen((stateChange) async {
    print('DISPOSABLE LISTENER ω :: Change event arrived!:'
        ' ${stateChange.event}');
    if (stateChange.event == ably.ConnectionEvent.connected) {
      await omegaSubscription.cancel();
    }
  });

  //RETAINING LISTENER - β
  realtime.connection.on().listen((stateChange) {
    print('RETAINING LISTENER β :: Change event arrived!:'
        ' ${stateChange.event}');
    // NESTED LISTENER - ξ
    // will be registered only when connected event is received by β listener
    realtime.connection.on().listen((stateChange) {
      // k ξ listeners will be registered
      // and each listener will be called `n-k` times respectively
      // if listener β is called `n` times
      print('NESTED LISTENER ξ: ${stateChange.event}');
    });
  });

  StreamSubscription preZetaSubscription;
  late StreamSubscription postZetaSubscription;
  preZetaSubscription = realtime.connection.on().listen((stateChange) {
    //This listener "pre ζ" will be cancelled from γ
    print('NESTED LISTENER "pre ζ": ${stateChange.event}');
  });

  //RETAINING LISTENER - γ
  realtime.connection.on().listen((stateChange) async {
    print(
        'RETAINING LISTENER γ :: Change event arrived!: ${stateChange.event}');
    if (stateChange.event == ably.ConnectionEvent.connected) {
      //by the time this cancel is triggered,
      // preZeta will already have received current event.
      await preZetaSubscription.cancel();

      //by the time this cancel is triggered,
      // postZeta hasn't received the event yet.
      // And will never receive as it is cancelled.
      await postZetaSubscription.cancel();
    }
  });

  postZetaSubscription = realtime.connection.on().listen((stateChange) {
    //This listener "post ζ" will be cancelled from γ
    print('NESTED LISTENER "post ζ": ${stateChange.event}');
  });
}
