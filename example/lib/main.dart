import 'dart:async';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'push_notifications/push_notification_handlers.dart';
import 'service/ably_service.dart';
import 'ui/ably_clients_sliver.dart';
import 'ui/push_notifications/push_notifications_sliver.dart';
import 'ui/realtime_sliver.dart';
import 'ui/rest_sliver.dart';

Future<void> main() async {
  // Before calling any Ably methods, ensure the widget binding is ready.
  WidgetsFlutterBinding.ensureInitialized();
  PushNotificationHandlers.setUpEventHandlers();
  PushNotificationHandlers.setUpMessageHandlers();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AblyService ablyService = AblyService();
  String? fullScreenExceptionMessage;
  bool isIOSSimulator = false;

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  Future<void> asyncInitState() async {
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      setState(() {
        isIOSSimulator = !iosInfo.isPhysicalDevice;
      });
    }
  }

  @override
  void dispose() {
    ablyService.close();
    super.dispose();
  }

  void showExceptionMessageToUser(String message) {
    setState(() {
      fullScreenExceptionMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (fullScreenExceptionMessage != null) {
      return MaterialApp(
          home: Scaffold(
        body: Container(
          child: Text(fullScreenExceptionMessage!),
        ),
      ));
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ably Plugin Example App'),
        ),
        body: Center(
          child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
              children: [
                SystemDetailsSliver(),
                const Divider(),
                AblyClientsSliver(ablyService, showExceptionMessageToUser),
                const Divider(),
                RealtimeSliver(ablyService),
                const Divider(),
                RestSliver(ablyService),
                const Divider(),
                PushNotificationsSliver(
                  ablyService.pushNotificationService,
                  isIOSSimulator: isIOSSimulator,
                )
              ]),
        ),
      ),
    );
  }
}
