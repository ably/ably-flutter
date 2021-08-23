# Push Notifications

## Known issues/ unimplemented:
- [Handling messages in the dart side](https://github.com/ably/ably-flutter/issues/141)
- [Activating devices from your server](https://ably.com/documentation/general/push/activate-subscribe#activation-from-server)
- [Push Admin API](https://ably.com/documentation/general/push/admin)

## Supported platforms
- iOS Device (not iOS Simulator)
- Android device
- Android emulator (with Google APIs)

## Setting up the Example App

To get push notifications setup in your own app, read [Setting up push notifications](#setting-up-push-notifications)
- Android:
    - Update the application ID (`applicationId "io.ably.flutter.plugin_example"`) in the example application in `example/android/app/build.gradle` to your unique application ID.
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
    - Create a firebase project
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

### Sending messages

- Create a rest or realtime client: e.g. `final realtime = ably.Realtime(options: clientOptions);`
- Activate the device for push notifications with Ably: `ablyClient.push.activate();`. This only
  needs to be done once, and will be used across all future app launches, as long as the app is not deactivated. This method will throw an AblyException if it fails.
- Listen to the `Push.pushEvents.onUpdateFailed` stream to be informed when a new token update (FCM registration token/ APNs device token) fails to be updated with Ably. If this update process fails, Ably servers
  will attempt to use the old tokens to send messages to devices and potentially fail. 
- Optional: listen to `Push.pushEvents.onActivate` and `Push.pushEvents.onDeactivate`. This is optional because `Push.activate` and `Push.deactivate` will return when it succeeds, and throw when it fails.
- Get the Realtime/ Rest channel: `final channel = realtime!.channels.get(Constants.channelNameForPushNotifications)`
- Subscribe the device to the **push channel**, by either using the device ID or client ID:
    - `channel.push.subscribeClient()` or `channel.push.subscribeDevice()`
- Optionally: List the subscriptions that the device or client is subscribed to: `final subscriptions = channel.push.listSubscriptions()`
- Your device is now ready to receive and display user notifications (called alert notifications on iOS and notifications on Android) to the user, when the application is in the background.



### Receiving messages

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
    'data': {'foo': 'bar', 'baz': 'quz'},
  },
}));
```
- To send a background/ data notification which will trigger the native code handler (Android) / delegate method (iOS), publish the following message to the channel:
    - Warning: Handling these messages on the dart side is currently not implemented. Track this in https://github.com/ably/ably-flutter/issues/141
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
