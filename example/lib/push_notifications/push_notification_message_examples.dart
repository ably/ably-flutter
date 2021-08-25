import 'package:ably_flutter/ably_flutter.dart' as ably;

class PushNotificationMessageExamples {
  static final ably.Message pushNotificationMessage = ably.Message(
      data: 'This is an Ably message published on channels that is also sent '
          'as a notification message to registered push devices.',
      extras: const ably.MessageExtras({
        'push': {
          'notification': {
            'title': 'Hello from Ably!',
            'body': 'Example push notification from Ably.',
            'sound': 'default'
          },
        },
      }));

  static ably.Message pushDataMessage = ably.Message(
      data: 'This is a Ably message published on channels that is also '
          'sent as a data message to registered push devices.',
      extras: const ably.MessageExtras({
        'push': {
          'data': {'foo': 'bar', 'baz': 'quz'},
          'apns': {
            'aps': {'content-available': 1}
          }
        },
      }));

  static ably.Message pushDataNotificationMessage = ably.Message(
      data: 'This is a Ably message published on channels that is also '
          'sent as a data message to registered push devices.',
      extras: const ably.MessageExtras({
        'push': {
          'notification': {
            'title': 'Hello from Ably!',
            'body': 'Example push notification from Ably.',
            'sound': 'default'
          },
          'data': {'foo': 'bar', 'baz': 'quz'},
          'apns': {
            'aps': {'content-available': 1}
          }
        },
      }));
}