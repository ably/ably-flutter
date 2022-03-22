import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';
import 'package:ably_flutter_example/ui/api_key_service.dart';

class AblyService {
  late final ably.Realtime realtime;
  late final ably.Rest rest;
  late final PushNotificationService pushNotificationService;
  late final ApiKeyProvision apiKeyProvision;

  AblyService({required this.apiKeyProvision}) {
    realtime = ably.Realtime(
      options: ably.ClientOptions(
        key: apiKeyProvision.key,
        clientId: Constants.clientId,
        logLevel: ably.LogLevel.verbose,
        environment: apiKeyProvision.source == ApiKeySource.env
            ? null
            : Constants.sandboxEnvironment,
        autoConnect: false,
      ),
    );
    rest = ably.Rest(
      options: ably.ClientOptions(
        key: apiKeyProvision.key,
        clientId: Constants.clientId,
        logLevel: ably.LogLevel.verbose,
        environment: apiKeyProvision.source == ApiKeySource.env
            ? null
            : Constants.sandboxEnvironment,
      ),
    );
    pushNotificationService = PushNotificationService(realtime, rest);
  }
}

class ExampleMessages {
  static ably.Message message = ably.Message(data: const {
    'I am': null,
    'and': {
      'also': 'nested',
      'too': {'deep': true}
    }
  });

  static List<ably.Message> messages = [
    ably.Message(data: 42),
    ably.Message(data: const {'are': 'you'}),
    ably.Message(data: 'ok?'),
    ably.Message(data: const [
      false,
      {
        'I am': null,
        'and': {
          'also': 'nested',
          'too': {'deep': true}
        }
      }
    ]),
  ];
}
