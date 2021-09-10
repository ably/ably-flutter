import '../../generated/platform_constants.dart';

class Notification {
  String title;
  String? body;

  Notification(this.title, this.body);

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
        map[TxNotification.title] as String,
        map[TxNotification.body] as String?);
  }
}
