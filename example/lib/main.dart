import 'package:ably_flutter_example/push_notifications/push_notification_handlers.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:ably_flutter_example/ui/api_key_service.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_sliver.dart';
import 'package:ably_flutter_example/ui/realtime_sliver.dart';
import 'package:ably_flutter_example/ui/rest_sliver.dart';
import 'package:ably_flutter_example/ui/system_details_sliver.dart';
import 'package:flutter/material.dart';

void main() async {
  // Before calling any Ably methods, ensure the widget binding is ready.
  WidgetsFlutterBinding.ensureInitialized();
  PushNotificationHandlers.setUpEventHandlers();
  PushNotificationHandlers.setUpMessageHandlers();
  // Because AblyService has to be initialized before runApp is called
  // provisioning also has to be done before the app starts
  final apiKeyProvision = await ApiKeyService().getOrProvisionApiKey();
  final ablyService = AblyService(apiKeyProvision: apiKeyProvision);
  runApp(AblyFlutterExampleApp(ablyService));
}

class AblyFlutterExampleApp extends StatelessWidget {
  final AblyService ablyService;

  AblyFlutterExampleApp(this.ablyService);

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
                  SystemDetailsSliver(ablyService.apiKeyProvision.key),
                  const Divider(),
                  RealtimeSliver(ablyService),
                  const Divider(),
                  RestSliver(ablyService.rest),
                  const Divider(),
                  PushNotificationsSliver(ablyService.pushNotificationService)
                ]),
          ),
        ),
      );
}
