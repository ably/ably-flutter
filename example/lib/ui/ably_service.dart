import 'package:ably_flutter/ably_flutter.dart' as ably;
import 'package:ably_flutter_example/constants.dart';
import 'package:ably_flutter_example/encrypted_messaging_service.dart';
import 'package:ably_flutter_example/push_notifications/push_notification_service.dart';

class AblyService {
  late final ably.Realtime realtime;
  late final ably.Rest rest;
  late final EncryptedMessagingService encryptedMessagingService;
  late final PushNotificationService pushNotificationService;

  AblyService(String _apiKey) {
    realtime = ably.Realtime(
        options: ably.ClientOptions.fromKey(_apiKey)
          ..clientId = Constants.clientId
          ..logLevel = ably.LogLevel.verbose
          ..autoConnect = false
          ..logHandler = ({msg, exception}) {
            print('Custom logger :: $msg $exception');
          });
    rest = ably.Rest(
        options: ably.ClientOptions.fromKey(_apiKey)
          ..clientId = Constants.clientId
          ..logLevel = ably.LogLevel.verbose
          ..logHandler = ({msg, exception}) {
            print('Custom logger :: $msg $exception');
          });
    encryptedMessagingService = EncryptedMessagingService(realtime, rest);
    pushNotificationService =
        PushNotificationService(realtime, rest);
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
