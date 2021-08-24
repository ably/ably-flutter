# Push Notifications

Push Notifications allow you to reach users who do not have your application open (in the foreground). On iOS, Ably connects to [APNs](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html) to send messages to devices. On Android, Ably connects to [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging/) to send messages to devices. As both services do not guarantee message delivery and may even throttle messages to specific devices based on battery level, message frequency, and other criteria, messages may arrive much later than sent or ignored.

## Known Limitations

- [Handling messages in the dart side](https://github.com/ably/ably-flutter/issues/141): Ably-flutter currently does not pass the messages to the Flutter application/ dart-side, so users will need to listen to messages in each platform. See [Implement Push Notifications listener](https://github.com/ably/ably-flutter/issues/141) for more information. 
      - On Android, this means implementing [`FirebaseMessageService`](https://firebase.google.com/docs/cloud-messaging/android/receive) and overriding `onMessageReceived` method. You must also declare the Service in your `AndroidManifest.xml`. 
          - On iOS, implementing the [`didReceiveRemoteNotification` delegate method](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application) declared in `UIApplicationDelegate`. 
- [Activating devices from your server](https://ably.com/documentation/general/push/activate-subscribe#activation-from-server): Device activation is automatic in Ably-flutter, just call `Push#activate`. However, Ably-java and ably-cocoa allow you to implement delegate methods to activate devices manually on your server instead of automatically.
- [Push Admin API](https://ably.com/documentation/general/push/admin): The Push APIs in this SDK are limited to managing the push notification features related to current device. The Push Admin API allows you to manage device registrations and subscriptions related to other devices. This is functionality designed for servers.

## Supported platforms
- iOS Device (not iOS Simulator)
- Android device
- Android emulator (with Google APIs)

## Setting up the Example App

To get push notifications setup in your own app, read [Setting up your own app](#setting-up-your-own-app)
- Android:
    - Update the application ID (`applicationId "io.ably.flutter.plugin_example"`) in the example application in `example/android/app/build.gradle` to a unique application ID.
    - Create a firebase project, and in the Project settings, add an Android App with your unique application ID. Follow the steps provided on the setup process, or the following:
        - You can leave `Debug signing certificate SHA-1` empty.
        - Download the generated `google-services.json` file
        - Place `google-services.json` in `example/android/app/`. We have `gitignore`d this file since it is associated with our firebase project, but it is [not sensitive](https://stackoverflow.com/questions/37358340/should-i-add-the-google-services-json-from-firebase-to-my-repository), so you can commit it to share it with other developers/ colleagues.
        - Update your build.gradle files according to the [Set up the SDK section](https://firebase.google.com/docs/cloud-messaging/android/client#set_up_the_sdk) of the firebase guide.
- iOS:
    - You need to have a [Apple developer program](https://developer.apple.com/programs/) membership ($99/year)
    - Open your iOS app in Xcode: when in your project directory, run `xed ios` or double click `ios/Runner.xcworkspace` in `your_project_name/ios`
        - Register your bundle ID on App Store connect.
        - Create a `.p12` certificate and upload it to the Ably dashboard to allow Ably to authenticate with APNs on behalf of you, using [How do I obtain the APNs certificates needed for iOS Push Notifications?](https://knowledge.ably.com/how-do-i-obtain-the-apns-certificates-needed-for-ios-push-notifications).
        - Add `Push Notifications` capability: Click Runner in project navigator, click `Runner` target, under the **Signing & Capabilities** tab, click `+ Capability`, and select `Push Notifications`.
        - Add `remote notification` Background mode:
            - Under the **Signing & Capabilities** tab, click `+ Capability` and select `Background Modes`.
            - Check `remote notifications`.

## Setting up your own App

- Android:
    - Create a firebase project if you do not have one
    - Set up firebase in your Android app, following the [Set up the SDK](https://firebase.google.com/docs/cloud-messaging/android/client#set_up_the_sdk) step.
    - Add your android app to the firebase project
    - In your firebase project settings, [create and add a server key](https://knowledge.ably.com/where-can-i-find-my-google/firebase-cloud-messaging-api-key), and enter it in your Ably app's dashboard (App > Notifications tab > Push Notifications Setup > Setup Push Notifications).
    - TODO: Update instructions here once I've tested in a fresh project.
- iOS:
    - You need to have a [Apple developer program](https://developer.apple.com/programs/) membership ($99/year)
    - Open your iOS app in Xcode: when in your project directory, run `xed ios` or double click `ios/Runner.xcworkspace` in `your_project_name/ios`
        - Register your bundle ID on App Store connect.
        - Create a `.p12` certificate and upload it to the Ably dashboard to allow Ably to authenticate with APNs on behalf of you, using [How do I obtain the APNs certificates needed for iOS Push Notifications?](https://knowledge.ably.com/how-do-i-obtain-the-apns-certificates-needed-for-ios-push-notifications).
        - Add `Push Notifications` capability: Click Runner in project navigator, click `Runner` target, under the **Signing & Capabilities** tab, click `+ Capability`, and select `Push Notifications`.
        - Add `remote notification` Background mode:
            - Under the **Signing & Capabilities** tab, click `+ Capability` and select `Background Modes`.
            - Check `remote notifications`.

## Usage

### Summary

Devices need to be [activated](#device-activation) with Ably once. Once activated, you can use their device ID, client ID or push token (APNs device token/ FCM registration token) to push messages to them using the Ably dashboard or a [Push Admin](https://ably.com/documentation/general/push/admin) (SDKs which provide push admin functionality, such as [Ably-java](https://github.com/ably/ably-java), [Ably-js](https://github.com/ably/ably-js), etc.). However, to send push notifications through Ably channels, devices need to [subscribe to the channel](#subscribing-to-channels). Once subscribed, messages on that channel with a [push payload](#creating-push-messages-payloads) will be sent to devices which are subscribed to that channel.

### Device activation

- Create a rest or realtime client: e.g. `final realtime = ably.Realtime(options: clientOptions);`
- Activate the device for push notifications with Ably: `ablyClient.push.activate();`. This only
  needs to be done once, and will be used across all future app launches, as long as the app is not deactivated. This method will throw an AblyException if it fails.
```dart
try {
  await push.activate();
} on ably.AblyException catch (error) {
  // Handle/ log the error.
}
```
- Listen to push events: You should listen to the `Push.pushEvents.onUpdateFailed` stream to be informed when a new token update (FCM registration token/ APNs device token) fails to be updated with Ably. If this update process fails, Ably servers will attempt to use the old tokens to send messages to devices and potentially fail.
    - Optional: listen to `Push.pushEvents.onActivate` and `Push.pushEvents.onDeactivate`. This is optional because `Push.activate` and `Push.deactivate` will return when it succeeds, and throw when it fails.
```dart
void main() {
  setUpPushEventHandlers();
  runApp(MyApp());
}

void setUpPushEventHandlers() {
  ably.Push.pushEvents.onUpdateFailed.listen((error) async {
    print(error);
  });
  ably.Push.pushEvents.onActivate.listen((error) async {
    print(error);
  });
  ably.Push.pushEvents.onDeactivate.listen((error) async {
    print(error);
  });
}
```

### Subscribing to channels

- Get the Realtime/ Rest channel: `final channel = realtime!.channels.get(Constants.channelNameForPushNotifications)`
- Subscribe the device to the **push channel**, by either using the device ID or client ID:
    - `channel.push.subscribeClient()` or `channel.push.subscribeDevice()`
- Your device is now ready to receive and display user notifications (called alert notifications on iOS and notifications on Android) to the user, when the application is in the background.
- For debugging: You could use the Ably dashboard (notification tab) or the Push Admin API using another SDK to ensure the device has been subscribed by listing the subscriptions on a specific channel. Alternatively, you can list the push channels the device or client is subscribed to: `final subscriptions = channel.push.listSubscriptions()`. This API requires Push Admin capability, and should be used for debugging. This means you must use an Ably API key or token with the `push-admin` capability.

### Notification Permissions (iOS only)

- Requesting permissions
  - Understand the iOS platform behaviour: 
    > The first time your app makes this authorization request, the system prompts the user to grant or deny the request and records the user’s response. Subsequent authorization requests don’t prompt the user. - [
    Asking Permission to Use Notifications](https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications)
    - This means it is important to choose the moment you request permission from the user. Once a user denies permission, you would need to ask the user to go into the Settings app and give your app permission manually.
  - Request permissions using `Push#requestPermission`, passing in options such as badge, sound, alert and provisional. See API documentation for more options.
  - To avoid showing the user a permission alert dialog, you can request provisional permissions with `Push#requestPermission(provisional: true)`. The notifications will be delivered silently to the notification center. 
    
```dart
// Create an Ably client to access the push field
final realtime = ably.Realtime(options: clientOptions);
final push = realtime.push;
// Request permission from user on iOS
bool permissionGranted = await push.requestPermission();
// Get more information about the notification settings
if (Platform.isIOS) {
  final notificationSettings = await realtime.push.getNotificationSettings();
}
```

### Sending messages

#### Sending notification messages
- To send a user notification, publish the following message to the channel:
```dart
final message = ably.Message(
  data: 'This is an Ably message published on channels that is also sent '
      'as a notification message to registered push devices.',
  extras: const ably.MessageExtras({
    'push': {
      'notification': {
        'title': 'Hello from Ably!',
        'body': 'Example push notification from Ably.'
    }, 
  },
}));
```

#### Sending data messages

```dart
final _pushDataMessage = ably.Message(
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
```

To have a data message arrive in the iOS, send a notification alongside the data message (i.e. a message which is simultaneously a notification and data message.) 

#### Sending a data & notification messages
```dart
final message = ably.Message(
  data: 'This is an Ably message published on channels that is also sent '
      'as a notification message to registered push devices.',
  extras: const ably.MessageExtras({
    'push': {
      'notification': {
        'title': 'Hello from Ably!',
        'body': 'Example push notification from Ably.'
    },
    'data': {'foo': 'bar', 'baz': 'quz'},
    'apns': {
    'aps': {'content-available': 1}
  },
}));
```

### Receiving messages

#### Notification messages

You cannot handle notification messages as they are shown to the user without calling any methods in your application. To create notifications which launch the application to a certain page (notifications which contain deep links, app links, URLs/ URL schemes or universal links), or notifications which contain buttons/ actions, images, and inline replies, you should send a [data message](#data-messages) and create a notification when the message is received. On Android, you can follow [Create a Notification](https://developer.android.com/training/notify-user/build-notification). On iOS, you can follow [Scheduling a Notification Locally from Your App](https://developer.apple.com/documentation/usernotifications/scheduling_a_notification_locally_from_your_app).

#### Data messages

Ably-flutter currently does not pass the messages to the Flutter application/ dart-side, so users will need to listen to messages in each platform. See [Implement Push Notifications listener](https://github.com/ably/ably-flutter/issues/141) for more information.
- On Android, this means implementing [`FirebaseMessageService`](https://firebase.google.com/docs/cloud-messaging/android/receive) and overriding `onMessageReceived` method. You must also declare the Service in your `AndroidManifest.xml`.
- On iOS, implementing the [`didReceiveRemoteNotification` delegate method](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application) declared in `UIApplicationDelegate`.
        - To send a background/ data notification which will trigger the native code handler (Android) / delegate method (iOS), publish the following message to the channel:
    
For further help on implementing the Platform specific message handlers, see "On Android" and "On iOS" sections on [Push Notifications - Device activation and subscription](https://ably.com/documentation/general/push/activate-subscribe).

### Deactivating the device

Do this only if you do not want the device to receive push notifications at all. You usually do not need to run this at all. 

```dart
    try {
      await push.deactivate();
    } on ably.AblyException catch (error) {
      // Handle/ log the error.
    }
```

## Troubleshooting/ FAQ

### Why are notifications not received when the app is open on Android?

When the app is in the foreground (open by the user), firebase messaging ignores the message. You would need to send a data message and build a local notification instead.

### Messaging generated from the "compose notification" in Firebase cloud messaging console are not received.

Ensure your Android app contains the firebase configuration `android/app/google-services.json` file. You can download this from your Firebase project settings.

### "FCM Reporting dashboard" in Firebase cloud messaging console does not show any messages being received.

You need to add the firebase-analytics dependency to your `app/build.gradle` file. This was optional when following the [Firebase Android client setup guide](https://firebase.google.com/docs/cloud-messaging/android/client), for example: `implementation 'com.google.firebase:firebase-analytics:version_number'`. Find the latest version number from [MVNRepository](https://mvnrepository.com/artifact/com.google.firebase/firebase-analytics).

### Why does my iOS device message not get received, and the error message returned is `BadDeviceToken`?

This is an error passed straight from APNs. Make sure the environment for push notifications on the app (`Runner.entitlements`) matches the environment set in Ably dashboard (push notification tab).

When running a debug application, the sandbox/ development APNs server would be used. Make sure to use an application with "Use APNS sandbox environment" enabled in the Ably dashboard (push notification tab).

You may try to change the `entitlements` file to `production` string, but this does not make the debug application use the production APNs server. For more information about this limitation, see [How do I make my debug app version receive production push notifications on iOS?](https://stackoverflow.com/a/46118155/7365866)

>**Debug** builds will always get *sandbox* APNS tokens.
>
>**Release** builds (ad-hoc or app store) will always get *production* APNS tokens.

For more information, take a look at [What are the possible reasons to get APNs responses BadDeviceToken or Unregistered?](https://stackoverflow.com/questions/42511476/what-are-the-possible-reasons-to-get-apns-responses-baddevicetoken-or-unregister).

### Push notification messages are not being delivered to my device, but normal messages in the same channel are.

From the [flutterfire guide](https://firebase.flutter.dev/docs/messaging/usage/) on firebase_messaging:

> For Android, you can view Logcat logs which will give a  descriptive message on why a notification was not delivered. On Apple platforms the "console.app" application will display "CANCELED" logs for those it chose to ignore, however doesn't provide a description as to why.

For Android, you can use logcat built into Android Studio or [pidcat](https://github.com/JakeWharton/pidcat) to view the logs. For iOS, we recommend you check the Console.app on your mac, looking for CANCELED logs to see if the device is throttling your usage of push notifications.

### Android only: When I look in ably.com's dashboard, i see "InvalidRegistration"

This means your registration token is invalid. Ably is may not have your device's FCM registration token. `FirebaseMessagingService.onNewToken` is only called when a new token is available, so if Ably was installed in a new app update and the token has **not** been changed, Ably won't know it. If you have previously registered with FCM without Ably, you should make sure to give ably the latest token, by getting it and calling:

  ```java
  ActivationContext.getActivationContext(this).onNewRegistrationToken(RegistrationToken.Type.FCM, registrationToken);
  ```