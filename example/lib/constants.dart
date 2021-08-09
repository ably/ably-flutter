import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';

class Constants {
  static const String ablyApiKey = 'ABLY_API_KEY';
  static String platform = EnumToString.convertToString(defaultTargetPlatform);
  static String clientId = 'ably-flutter-example-app-$platform-client-id';
  static const String channelName = 'test-channel';
  static const String channelNameForPushNotifications =
      'push:test-push-channel';
  static const String pushMetaChannelName = '[meta]log:push';
}
