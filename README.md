# Ably Flutter Plugin

[![.github/workflows/check.yaml](https://github.com/ably/ably-flutter/actions/workflows/check.yaml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/check.yaml)
[![.github/workflows/docs.yml](https://github.com/ably/ably-flutter/actions/workflows/docs.yml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/docs.yml)
[![.github/workflows/flutter_integration.yaml](https://github.com/ably/ably-flutter/actions/workflows/flutter_integration.yaml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/flutter_integration.yaml)

A
[Flutter](https://flutter.dev/)
plugin wrapping the
[ably-cocoa](https://github.com/ably/ably-cocoa) (iOS)
and
[ably-java](https://github.com/ably/ably-java) (Android)
client library SDKs for [Ably](https://www.ably.com),
the platform that powers synchronized digital experiences in realtime.

Ably provides the best infrastructure and APIs to power realtime experiences at scale, delivering billions of realtime messages everyday to millions of end users.
We handle the complexity of realtime messaging so you can focus on your code.

## Resources

- [Quickstart Guide](https://www.ably.com/documentation/quick-start-guide?lang=flutter)
- [Introducing the Ably Flutter plugin](https://www.ably.com/blog/ably-flutter-plugin) by [Srushtika](https://github.com/Srushtika) (Developer Advocate)
- [Building a Realtime Cryptocurrency App with Flutter](https://www.ably.com/tutorials/realtime-cryptocurrency-app-flutter) by [pr-Mais](https://github.com/pr-Mais) and [escamoteur](https://github.com/escamoteur)
- [Building realtime apps with Flutter and WebSockets: client-side considerations](https://www.ably.com/topic/websockets-flutter)

## Supported Platforms

### iOS

iOS 10 or newer.

### Android

API Level 19 (Android 4.4, KitKat) or newer.

_This project uses Java 8 language features, utilising [Desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring)
to support lower versions of the Android runtime (i.e. API Levels prior to 24)_

If your project needs support for SDK Version lower than 24, Android Gradle Plugin 4.0.0+ must be used.
You might also need to upgrade [gradle distribution](https://developer.android.com/studio/releases/gradle-plugin#updating-plugin) accordingly.

## Known Limitations

Features that we do not currently support, but we do plan to add in the future:

- Symmetric encryption ([#104](https://github.com/ably/ably-flutter/issues/104))
- Ably token generation ([#105](https://github.com/ably/ably-flutter/issues/105))
- REST and Realtime Stats ([#106](https://github.com/ably/ably-flutter/issues/106))
- Push Notifications target ([#107](https://github.com/ably/ably-flutter/issues/107))
- Custom transportParams ([#108](https://github.com/ably/ably-flutter/issues/108))
- Push Notifications Admin ([#109](https://github.com/ably/ably-flutter/issues/109))
- Remember fallback host during failures ([#47](https://github.com/ably/ably-flutter/issues/47))

## Running the example

- Clone the repo
- cd to `example` folder
- run `flutter pub get` to install dependencies
- Get/ create an Ably API key from your account on ably.com
    - If starting the app using the command line, run `flutter run --dart-define=ABLY_API_KEY=put_your_api_key_here`
    - If starting the app using Android Studio:
        - Edit the example app run configuration
          add the --dart-define flag to `additional run args`
- Android only: Create a firebase project, add an Android app to it, add download a `google-services.json` file. Move this file to `example/android/app`. This is required because we depend on Firebase, which requires this file at launch. 
- `flutter run` will start the application on connected android / iOS device

## Usage

### Specify Dependency

Package home:
[pub.dev/packages/ably_flutter](https://pub.dev/packages/ably_flutter)

See:
[Adding a package dependency to an app](https://flutter.dev/docs/development/packages-and-plugins/using-packages#adding-a-package-dependency-to-an-app)

### Import the package

```dart
import 'package:ably_flutter/ably_flutter.dart' as ably;
```

### Configure a Client Options object

```dart
final clientOptions = ably.ClientOptions.fromKey("<YOUR APP KEY>");
clientOptions.logLevel = ably.LogLevel.verbose;  // optional
```

### Using the REST API

Creating the REST client instance:

```dart
ably.Rest rest = ably.Rest(options: clientOptions);
```

Getting a channel instance

```dart
ably.RestChannel channel = rest.channels.get('test');
```

Publishing messages using REST:

```dart
// both name and data
await channel.publish(name: "Hello", data: "Ably");

// just name
await channel.publish(name: "Hello");

// just data
await channel.publish(data: "Ably");

// an empty message
await channel.publish();
```

Get REST history:

```dart
void getHistory([ably.RestHistoryParams params]) async {
  // getting channel history, by passing or omitting the optional params
  var result = await channel.history(params);

  var messages = result.items;        // get messages
  var hasNextPage = result.hasNext(); // tells whether there are more results
  if (hasNextPage) {    
    result = await result.next();     // will fetch next page results
    messages = result.items;
  }
  if (!hasNextPage) {
    result = await result.first();    // will fetch first page results
    messages = result.items;
  }
}

// history with default params
getHistory();

// sorted and filtered history
getHistory(ably.RestHistoryParams(direction: 'forwards', limit: 10));
```

Get REST Channel Presence:

```dart
void getPresence([ably.RestPresenceParams params]) async {
  // getting channel presence members, by passing or omitting the optional params
  var result = await channel.presence.get(params);

  var presenceMembers = result.items; // returns PresenceMessages
  var hasNextPage = result.hasNext(); // tells whether there are more results
  if (hasNextPage) {
    result = await result.next();     // will fetch next page results
    presenceMembers = result.items;
  }
  if (!hasNextPage) {
    result = await result.first();    // will fetch first page results
    presenceMembers = result.items;
  }
}

// getting presence members with default params
getPresence();

// filtered presence members
getPresence(ably.RestPresenceParams(
  limit: 10,
  clientId: '<clientId>',
  connectionId: '<connectionID>',
));
```

Get REST Presence History:

```dart
void getPresenceHistory([ably.RestHistoryParams params]) async {

  // getting channel presence history, by passing or omitting the optional params
  var result = await channel.presence.history(params);

  var presenceHistory = result.items; // returns PresenceMessages
  var hasNextPage = result.hasNext(); // tells whether there are more results
  if (hasNextPage) {
    result = await result.next();     // will fetch next page results
    presenceHistory = result.items;
  }
  if (!hasNextPage) {
    result = await result.first();    // will fetch first page results
    presenceHistory = result.items;
  }
}

// getting presence members with default params
getPresenceHistory();

// filtered presence members
getPresenceHistory(ably.RestHistoryParams(direction: 'forwards', limit: 10));
```

### Using the Realtime API

Creating the Realtime client instance:

```dart
ably.Realtime realtime = ably.Realtime(options: clientOptions);
```

Listening for connection state change events:

```dart
realtime.connection
  .on()
  .listen((ably.ConnectionStateChange stateChange) async {
    print('Realtime connection state changed: ${stateChange.event}');
    setState(() {
      _realtimeConnectionState = stateChange.current;
    });
});
```

Listening for a particular connection state change event (e.g. `connected`):

```dart
realtime.connection
  .on(ably.ConnectionEvent.connected)
  .listen((ably.ConnectionStateChange stateChange) async {
    print('Realtime connection state changed: ${stateChange.event}');
    setState(() {
      _realtimeConnectionState = stateChange.current;
    });
});
```

Creating a Realtime channel instance:

```dart
ably.RealtimeChannel channel = realtime.channels.get('channel-name');
```

Listening for channel events:

```dart
channel.on().listen((ably.ChannelStateChange stateChange) {
  print("Channel state changed: ${stateChange.current}");
});
```

Attaching to the channel:

```dart
await channel.attach();
```

Detaching from the channel:

```dart
await channel.detach();
```

Subscribing to messages on the channel:

```dart
var messageStream = channel.subscribe();
var channelMessageSubscription = messageStream.listen((ably.Message message) {
  print("New message arrived ${message.data}");
});
```

Use `channel.subscribe(name: "event1")` or `channel.subscribe(names: ["event1", "event2"])` to listen to specific named messages.

UnSubscribing from receiving messages on the channel:

```dart
await channelMessageSubscription.cancel();
```

Publishing channel messages

```dart
// both name and data
await channel.publish(name: "event1", data: "hello world");
await channel.publish(name: "event1", data: {"hello": "world", "hey": "ably"});
await channel.publish(name: "event1", data: [{"hello": {"world": true}, "ably": {"serious": "realtime"}]);

// single message
await channel.publish(message: ably.Message()..name = "event1"..data = {"hello": "world"});

// multiple messages
await channel.publish(messages: [
  ably.Message()..name="event1"..data = {"hello": "ably"},
  ably.Message()..name="event1"..data = {"hello": "world"}
]);
```

Get Realtime history

```dart
void getHistory([ably.RealtimeHistoryParams params]) async {
  var result = await channel.history(params);

  var messages = result.items;        // get messages
  var hasNextPage = result.hasNext(); // tells whether there are more results
  if (hasNextPage) {    
    result = await result.next();     // will fetch next page results
    messages = result.items;
  }
  if (!hasNextPage) {
    result = await result.first();    // will fetch first page results
    messages = result.items;
  }
}

// history with default params
getHistory();

// sorted and filtered history
getHistory(ably.RealtimeHistoryParams(direction: 'forwards', limit: 10));
```

Enter Realtime Presence:

```dart
await channel.presence.enter();

// with data
await channel.presence.enter("hello");
await channel.presence.enter([1, 2, 3]);
await channel.presence.enter({"key": "value"});

// with Client ID
await channel.presence.enterClient("user1");

// with Client ID and data
await channel.presence.enterClient("user1", "hello");
await channel.presence.enterClient("user1", [1, 2, 3]);
await channel.presence.enterClient("user1", {"key": "value"});
```

Update Realtime Presence:

```dart
await channel.presence.update();

// with data
await channel.presence.update("hello");
await channel.presence.update([1, 2, 3]);
await channel.presence.update({"key": "value"});

// with Client ID
await channel.presence.updateClient("user1");

// with Client ID and data
await channel.presence.updateClient("user1", "hello");
await channel.presence.updateClient("user1", [1, 2, 3]);
await channel.presence.updateClient("user1", {"key": "value"});
```

Leave Realtime Presence:

```dart
await channel.presence.leave();

// with data
await channel.presence.leave("hello");
await channel.presence.leave([1, 2, 3]);
await channel.presence.leave({"key": "value"});

// with Client ID
await channel.presence.leaveClient("user1");

// with Client ID and data
await channel.presence.leaveClient("user1", "hello");
await channel.presence.leaveClient("user1", [1, 2, 3]);
await channel.presence.leaveClient("user1", {"key": "value"});
```

Get Realtime Presence members:

```dart
var presenceMessages = await channel.presence.get();

// filter by Client Id
var presenceMessages = await channel.presence.get(
  ably.RealtimePresenceParams(
    clientId: 'clientId',
  ),
);

// filter by Connection Id
var presenceMessages = await channel.presence.get(
  ably.RealtimePresenceParams(
    connectionId: 'connectionId',
  ),
);
```

Get Realtime Presence history

```dart
void getPresenceHistory([ably.RealtimeHistoryParams params]) async {
  var result = await channel.presence.history(params);

  var messages = result.items;        // get messages
  var hasNextPage = result.hasNext(); // tells whether there are more results
  if (hasNextPage) {    
    result = await result.next();     // will fetch next page results
    messages = result.items;
  }
  if (!hasNextPage) {
    result = await result.first();    // will fetch first page results
    messages = result.items;
  }
}

// presence history with default params
getPresenceHistory();

// sorted and filtered history
getPresenceHistory(ably.RealtimeHistoryParams(direction: 'forwards', limit: 10));
```

Subscribe to Realtime Presence messages

```dart
// subscribe for all presence actions
channel
  .presence
  .subscribe()
  .listen((presenceMessage) {
    print(presenceMessage);
  },
);

// subscribe for specific action
channel
  .presence
  .subscribe(action: PresenceAction.enter)
  .listen((presenceMessage) {
    print(presenceMessage);
  },
);

// subscribe for multiple actions
channel
  .presence
  .subscribe(actions: [
    PresenceAction.enter,
    PresenceAction.update,
  ])
  .listen((presenceMessage) {
    print(presenceMessage);
  },
);
```

### Push Notifications

#### Setting up push notifications

- To get push notifications working in the example app:
    - For Android 🤖:
        - Update the application ID (`applicationId "io.ably.flutter.plugin_example"`) in the example application in `example/android/app/build.gradle` to your unique application ID.
        - Create a firebase project, and in the Project settings, add an Android App. Follow the steps provided on the setup process, or the following:
            - Specify your application ID in this step.
            - You can leave `Debug signing certificate SHA-1` empty.
            - Download the generated `google-services.json` file
            - Place `google-services.json` in `example/android/app/`. We have `gitignore`d this file since it is associated with our firebase project, but it is [not sensitive](https://stackoverflow.com/questions/37358340/should-i-add-the-google-services-json-from-firebase-to-my-repository), so you can commit it to share it with other developers/ colleagues.
            - Update your build.gradle files according to the [Set up the SDK section](https://firebase.google.com/docs/cloud-messaging/android/client#set_up_the_sdk) of the firebase guide.
            - Declare the AblyPushNotificationService: In `AndroidManifest.xml`, declare a service already implemented in ably-flutter by adding the following between the `<application>` and `</application>` tags:
```xml
<service android:name="io.ably.flutter.plugin.push.AblyPushNotificationService">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```
    - For iOS 📱:
        - You need to have a [Apple developer program](https://developer.apple.com/programs/) membership ($99/year)
        - Open your iOS app in Xcode: when in your project directory, run `xed ios` or double click `ios/Runner.xcworkspace` in `your_project_name/ios`
            - Register your bundle ID on App Store connect.
            - Create a `.p12` certificate and upload it to the Ably dashboard to allow Ably to authenticate with APNs on behalf of you, using [How do I obtain the APNs certificates needed for iOS Push Notifications?](https://knowledge.ably.com/how-do-i-obtain-the-apns-certificates-needed-for-ios-push-notifications).
            - Add `Push Notifications` capability: Click Runner in project navigator, click `Runner` target, under the **Signing & Capabilities** tab, click `+ Capability`, and select `Push Notifications`.
            - Add `remote notification` Background mode:
                - Under the **Signing & Capabilities** tab, click `+ Capability` and select `Background Modes`.
                - Check `remote notifications`.

#### Usage
- Create a rest or realtime client: e.g. `final realtime = ably.Realtime(options: clientOptions);`
- Activate the device for push notifications with Ably: `ablyClient.push.activate();`. This only 
  needs to be done once.
- Get the Realtime/ Rest channel: `final channel = realtime!.channels.get(Constants.channelNameForPushNotifications)`
- Subscribe the device to the channel, by either using the deviceID or client ID:
  - `channel.push.subscribeClient()` or `channel.push.subscribeDevice()` 
- Optionally: List the subscriptions that the device or client is subscribed to: `final subscriptions = channel.push.listSubscriptions()`
- Your device is now ready to receive and display user notifications (called alert notifications on iOS and notifications on Android) to the user, when the application is in the background. 
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
## Caveats

### RTE6a compliance

Using the Streams based approach doesn't fully conform with
[RTE6a](https://docs.ably.com/client-lib-development-guide/features/#RTE6a)
from our
[client library features specification](https://docs.ably.com/client-lib-development-guide/features/).

#### The Problem

```dart
StreamSubscription subscriptionToBeCancelled;

// Listener registered 1st
realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
  if (stateChange.event == ably.ConnectionEvent.connected) {
    await subscriptionToBeCancelled.cancel();       // Cancelling 2nd listener
  }
});

// Listener registered 2nd
subscriptionToBeCancelled = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
  print('State changed');
});
```

In the example above, the 2nd listener is cancelled when the 1st listener is notified about the "connected" event.
As per
[RTE6a](https://docs.ably.com/client-lib-development-guide/features/#RTE6a),
the 2nd listener should also be triggered.
It will not be as the 2nd listener was registered after the 1st listener and stream subscription is cancelled immediately after 1st listener is triggered.

This wouldn't have happened if the 2nd listener had been registered before the 1st was.

However, using a neat little workaround will fix this...

#### The Workaround - Cancelling using delay

Instead of `await subscriptionToBeCancelled.cancel();`, use

```dart
Future.delayed(Duration.zero, () {
    subscriptionToBeCancelled.cancel();
});
```

## Contributing

For guidance on how to contribute to this project, see [CONTRIBUTING.md](CONTRIBUTING.md).
