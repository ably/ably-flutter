import 'package:flutter/cupertino.dart';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:flutter/material.dart';

class PushNotificationHandlers {
  static BuildContext? context;

  static void setUpEventHandlers() {
    ably.Push.pushEvents.onUpdateFailed.listen((error) async {
      print(error);
    });
    ably.Push.pushEvents.onActivate.listen((error) async {
      print(error);
    });
    ably.Push.pushEvents.onDeactivate.listen((error) async {
      print(error);
    });
  }
}
