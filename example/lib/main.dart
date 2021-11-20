import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_handlers.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:ably_flutter_example/ui/message_encryption/message_encryption_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_sliver.dart';
import 'package:ably_flutter_example/ui/realtime_sliver.dart';
import 'package:ably_flutter_example/ui/rest_sliver.dart';
import 'package:ably_flutter_example/ui/system_details_sliver.dart';
import 'package:flutter/material.dart';

void main() {
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

const defaultChannel = Constants.channelName;

class _MyAppState extends State<MyApp> {
  final String _apiKey = const String.fromEnvironment(Constants.ablyApiKey);
  late final AblyService _ablyService = AblyService(_apiKey);

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Ably Flutter Example App'),
          ),
          body: Center(
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                children: [
                  SystemDetailsSliver(_apiKey),
                  const Divider(),
                  RealtimeSliver(_ablyService),
                  const Divider(),
                  RestSliver(_ablyService.rest),
                  const Divider(),
                  MessageEncryptionSliver(
                      _ablyService.encryptedMessagingService),
                  const Divider(),
                  PushNotificationsSliver(_ablyService.pushNotificationService)
                ]),
          ),
        ),
      );
}
