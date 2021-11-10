import 'package:ably_flutter/src/generated/platform_constants.dart';

class Notification {
  String title;
  String? body;

  Notification(this.title, this.body);

  factory Notification.fromMap(Map<String, dynamic> map) => Notification(
      map[TxNotification.title] as String, map[TxNotification.body] as String?);
}
