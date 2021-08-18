import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class AndroidPushNotificationConfiguration {
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AndroidPushNotificationConfiguration() {
    setUpAndroidNotificationChannels();
  }

  Future<void> setUpAndroidNotificationChannels() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

}