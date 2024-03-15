import 'package:ably_flutter_example/push_notifications/push_notification_handlers.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:ably_flutter_example/ui/api_key_service.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_sliver.dart';
import 'package:ably_flutter_example/ui/realtime_sliver.dart';
import 'package:ably_flutter_example/ui/rest_sliver.dart';
import 'package:ably_flutter_example/ui/system_details_sliver.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Before calling any Ably methods, ensure the widget binding is ready.
  WidgetsFlutterBinding.ensureInitialized();
  PushNotificationHandlers.setUpEventHandlers();
  PushNotificationHandlers.setUpMessageHandlers();
  // Because AblyService has to be initialized before runApp is called
  // provisioning also has to be done before the app starts
  final apiKeyProvision = await ApiKeyService().getOrProvisionApiKey();
  runApp(AblyFlutterExampleApp(apiKeyProvision: apiKeyProvision));
}

class AblyFlutterExampleApp extends StatefulWidget {
  final ApiKeyProvision apiKeyProvision;

  const AblyFlutterExampleApp({
    required this.apiKeyProvision,
    Key? key,
  }) : super(key: key);

  @override
  State<AblyFlutterExampleApp> createState() => _AblyFlutterExampleAppState();
}

class _AblyFlutterExampleAppState extends State<AblyFlutterExampleApp> {
  AblyService? ablyService;
  String clientId = '';

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Ably Flutter Example App'),
          ),
          body: Center(
            child: ablyService == null
                ? ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 36),
                    children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Client ID',
                          ),
                          onChanged: (value) {
                            setState(() {
                              clientId = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              ablyService = AblyService(
                                  apiKeyProvision: widget.apiKeyProvision,
                                  clientId: clientId);
                            });
                          },
                          child: const Text('Submit'),
                        )
                      ])
                : AblyFlutterExampleContent(
                    ablyService: ablyService!,
                    onLogout: () {
                      setState(() {
                        ablyService = null;
                      });
                    }),
          ),
        ),
      );
}

class AblyFlutterExampleContent extends StatelessWidget {
  final AblyService ablyService;
  final void Function() onLogout;

  const AblyFlutterExampleContent({
    required this.ablyService,
    required this.onLogout,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
          children: [
            ElevatedButton(
              onPressed: onLogout,
              child: const Text('Logout'),
            ),
            SystemDetailsSliver(
              apiKeyProvision: ablyService.apiKeyProvision,
              clientId: ablyService.clientId,
            ),
            const Divider(),
            RealtimeSliver(ablyService),
            const Divider(),
            RestSliver(ablyService.rest),
            const Divider(),
            PushNotificationsSliver(ablyService.pushNotificationService)
          ]);
}
