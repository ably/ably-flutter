import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';

class AblyService {
  final String apiKey = const String.fromEnvironment(Constants.ablyApiKey);
  late final ably.Realtime realtime;
  late final ably.Rest rest;
  late final PushNotificationService pushNotificationService;

  AblyService() {
    realtime = ably.Realtime(
        options: ably.ClientOptions.fromKey(apiKey)
          ..clientId = Constants.clientId
          ..logLevel = ably.LogLevel.verbose
          ..autoConnect = false
          ..logHandler = ({msg, exception}) {
            print('Custom logger :: $msg $exception');
          });
    rest = ably.Rest(
        options: ably.ClientOptions.fromKey(apiKey)
          ..clientId = Constants.clientId
          ..logLevel = ably.LogLevel.verbose
          ..logHandler = ({msg, exception}) {
            print('Custom logger :: $msg $exception');
          });
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
