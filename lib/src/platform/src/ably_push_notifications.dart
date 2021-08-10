part of ably_flutter;

// Flutter Firebase messaging library just has 1, because they use RemoteMessage from the ios firebase library.
// We currently don't have a firebase dependency on iOS.
typedef IOSBackgroundMessageHandler = Future<void> Function(APNsRemoteNotification message);
typedef AndroidBackgroundMessageHandler = Future<void> Function(FirebaseRemoteMessage message);

class AblyPushNotifications {

  static void setIOSBackgroundMessageHandler(IOSBackgroundMessageHandler handler) {

  }

  static setAndroidBackgroundMessageHandler(AndroidBackgroundMessageHandler handler) {

  }
}

class APNsRemoteNotification {

}

class FirebaseRemoteMessage {

}