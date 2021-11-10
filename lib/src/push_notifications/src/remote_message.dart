import 'package:ably_flutter/ably_flutter.dart';
import 'package:ably_flutter/src/platform/platform_internal.dart';

class RemoteMessage {
  late Map<String, dynamic> data;
  Notification? notification;

  RemoteMessage({Map<String, dynamic>? data, this.notification}) {
    if (data == null) {
      data = {};
    } else {
      this.data = data;
    }
  }

  factory RemoteMessage.fromMap(Map<String, dynamic> map) => RemoteMessage(
      data: map[TxRemoteMessage.data] == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(
              map[TxRemoteMessage.data] as Map<dynamic, dynamic>),
      notification: map[TxRemoteMessage.notification] == null
          ? null
          : Notification.fromMap(Map<String, dynamic>.from(
              map[TxRemoteMessage.notification] as Map<dynamic, dynamic>)));
}
