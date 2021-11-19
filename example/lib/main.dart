import 'dart:async';
import 'dart:io';

import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_handlers.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/ably_service.dart';
import 'package:ably_flutter_example/ui/message_encryption/message_encryption_sliver.dart';
import 'package:ably_flutter_example/ui/push_notifications/push_notifications_sliver.dart';
import 'package:ably_flutter_example/ui/realtime_sliver.dart';
import 'package:ably_flutter_example/ui/rest_sliver.dart';
import 'package:ably_flutter_example/ui/system_details_sliver.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

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

const defaultChannel = Constants.channelName;

class _MyAppState extends State<MyApp> {
  final String _apiKey = const String.fromEnvironment(Constants.ablyApiKey);
  ably.Realtime? _realtime;
  ably.Rest? _rest;
  ably.ChannelState? _realtimeChannelState;
  final _subscriptionsToDispose = <StreamSubscription>[];
  ably.Message? channelMessage;
  StreamSubscription<ably.PresenceMessage?>?
      _channelPresenceMessageSubscription;
  ably.PresenceMessage? channelPresenceMessage;
  List<ably.PresenceMessage>? _realtimePresenceMembers;
  late final PushNotificationService _pushNotificationService =
      PushNotificationService();
  late final AblyService _ablyService = AblyService(_apiKey);
  bool isIOSSimulator = false;

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  @override
  void dispose() {
    // This dispose would not be effective in this example as this is
    // a single view but subscriptions must be disposed when listeners are
    // implemented in the actual application
    //
    // See: https://api.flutter.dev/flutter/widgets/State/dispose.html
    for (final s in _subscriptionsToDispose) {
      s.cancel();
    }
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> asyncInitState() async {
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      setState(() {
        isIOSSimulator = !iosInfo.isPhysicalDevice;
      });
    }

    _pushNotificationService
      ..setRealtimeClient(_realtime!)
      ..setRestClient(_rest!);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Ably Plugin Example App'),
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
                  PushNotificationsSliver(
                    _pushNotificationService,
                    isIOSSimulator: isIOSSimulator,
                  )
                ]),
          ),
        ),
      );
}
