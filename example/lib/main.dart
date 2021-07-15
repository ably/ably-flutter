import 'package:flutter/material.dart';

import 'service/ably_service.dart';
import 'ui/ably_clients_sliver.dart';
import 'ui/push_notifications_sliver.dart';
import 'ui/realtime_sliver.dart';
import 'ui/rest_sliver.dart';
import 'ui/system_details_sliver.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AblyService ablyService = AblyService();
  String? fullScreenExceptionMessage;

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
                PushNotificationsSliver(ablyService)
              ]),
        ),
      ),
    );
  }
}
