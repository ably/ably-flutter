# Ably Flutter Plugin

[![https://pub.dev/packages/ably_flutter](https://img.shields.io/pub/v/ably_flutter)](https://pub.dev/packages/ably_flutter)
[![.github/workflows/check.yaml](https://github.com/ably/ably-flutter/actions/workflows/check.yaml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/check.yaml)
[![.github/workflows/docs.yml](https://github.com/ably/ably-flutter/actions/workflows/docs.yml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/docs.yml)
[![.github/workflows/flutter_integration.yaml](https://github.com/ably/ably-flutter/actions/workflows/flutter_integration.yaml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/flutter_integration.yaml)

_[Ably](https://ably.com) is the platform that powers synchronized digital experiences in realtime. Whether attending an event in a virtual venue, receiving realtime financial information, or monitoring live car performance data – consumers simply expect realtime digital experiences as standard. Ably provides a suite of APIs to build, extend, and deliver powerful digital experiences in realtime for more than 250 million devices across 80 countries each month. Organizations like Bloomberg, HubSpot, Verizon, and Hopin depend on Ably’s platform to offload the growing complexity of business-critical realtime data synchronization at global scale. For more information, see the [Ably documentation](https://ably.com/documentation)._

## Overview

A [Flutter](https://flutter.dev/) plugin for [Ably](https://www.ably.com),
built on top of Ably's [iOS](https://github.com/ably/ably-cocoa) and [Android](https://github.com/ably/ably-java) SDKs.

## Running the example

### Authorization in the example app

There are two different ways the example application can be configured to use Ably services:

1. Without the Ably SDK key: the application will request a sandbox key provision from Ably server at startup, but be aware that:

    - provisioned key may not support all features available in Ably SDK.
    - provisioned keys aren't able to use Ably push notifications. This feature requires APNS and FCM identifiers to be registered for Ably instance, which can't be done with sandbox applications
    - provisioned key will change on application restart

2. With the Ably SDK key: you can create a free account on [ably.com](https://ably.com/) and then use your API key from there in the example app. This approach will give you much more control over the API capabilities and grant access to development console, where API communication can be conveniently inspected.

#### Android Studio / IntelliJ Idea

Under the run/ debug configuration drop down menu, click `Edit Configurations...`. Duplicate the `Example App (Duplicate and modify)` configuration. Leave the "Store as project file" unchecked to avoid committing your Ably API key into a repository. Update this new run configuration's `additional run args` with your ably API key. Run or debug the your new run/ debug configuration.

![Drop down menu for Run/Debug Configurations in Android Studio](https://github.com/ably/ably-flutter/raw/main/images/run-configuration-1.png)

![Run/Debug Configurations window in Android Studio](https://github.com/ably/ably-flutter/raw/main/images/run-configuration-2.png)

#### Visual Studio Code

- Under `Run and Debug`,
  - Select the gear icon to view [launch.json](.vscode/launch.json)
  - Find `Example App` launch configuration
  - Add your Ably API key to the `configurations.args`, i.e. replace `replace_with_your_api_key` with your own Ably API key.
  - Choose a device to launch the app:
    - to launch on a device, make sure it is the only device plugged in.
    - to run on a specific device when you have multiple plugged in, add another element to the `configuration.args` value, with `--device-id=replace_with_device_id`. Make sure to replace `replace_with_your_device` with your device ID from `flutter devices`.
- From `Run and Debug` select the `Example App` configuration and run it

#### Command Line using the Flutter Tool

- Change into the example app directory: `cd example`
- Install dependencies: `flutter pub get`
- Launch the application: `flutter run --dart-define ABLY_API_KEY=put_your_ably_api_key_here`, remembering to replace `put_your_ably_api_key_here` with your own API key.
  - To choose a specific device when more than one are connected: get your device ID using `flutter devices`, and then running `flutter run --dart-define=ABLY_API_KEY=put_your_ably_api_key_here --device-id replace_with_device_id`

### Push Notifications

By default, push-related components in the sample app won't work on Android, because of a dummy [google-services.json](example/android/app/src/google-services.json) file. In order to use push messaging features of Ably SDK, additional FCM/APNS configuration is required.

See [PushNotifications.md](PushNotifications.md) for detailed information on getting PN working with the example app.

## Installation

### Specify Dependency

In `pubspec.yaml` file:

```yaml
dependencies:
  ably_flutter: ^1.2.14
```

### Import the package

```dart
import 'package:ably_flutter/ably_flutter.dart' as ably;
```

## Usage

### Configure a Client Options object

For guidance on selecting an authentication method (basic authentication vs. token authentication), read [Selecting an authentication mechanism](https://ably.com/docs/core-features/authentication/#selecting-auth).

Authenticating using [basic authentication/ API key](https://ably.com/docs/core-features/authentication/#basic-authentication) (for running example app/ test apps and not for production)

```dart
// Specify your apiKey with `flutter run --dart-define=ABLY_API_KEY=replace_your_api_key`
final String ablyApiKey = const String.fromEnvironment("ABLY_API_KEY");
final clientOptions = ably.ClientOptions(key: ablyApiKey);
clientOptions.logLevel = ably.LogLevel.verbose;  // optional
```

Authenticating using [token authentication](https://ably.com/docs/core-features/authentication/#token-authentication)

```dart
// Used to create a clientId when a client first doesn't have one. 
// Note: you should implement `createTokenRequest`, which makes a request to your server that uses your Ably API key directly.
final clientOptions = ably.ClientOptions()
  // If a clientId was set in ClientOptions, it will be available in the authCallback's first parameter (ably.TokenParams).
  ..clientId = _clientId
  ..authCallback = (ably.TokenParams tokenParams) async {
    try {
      // Send the tokenParamsMap (Map<String, dynamic>) to your server, using it to create a TokenRequest.
      final Map<String, dynamic> tokenRequestMap = await createTokenRequest(
              tokenParams.toMap());
      return ably.TokenRequest.fromMap(tokenRequestMap);
    } on http.ClientException catch (e) {
      print('Failed to createTokenRequest: $e');
      rethrow;
    }
  };
final realtime = ably.Realtime(options: clientOptions);
```

An example of `createTokenRequest`'s implementation making a network request to your server could be:

```dart
Future<Map<String, dynamic>> createTokenRequest(
    Map<String, dynamic> tokenParamsMap) async {
  var url = Uri.parse('https://example.com/api/v1/createTokenRequest');
  // For debugging:
  bool runningServerLocally = true;
  if (runningServerLocally) {
    if (Platform.isAndroid) { // Connect Android device to local server
      url = Uri.parse(
          'http://localhost:6001/api/v1/createTokenRequest');
    } else if (Platform.isIOS) { // Connect iOS device to local server
      const localDeviceIPAddress = '192.168.1.9';
      url = Uri.parse(
          'http://$localDeviceIPAddress:6001/api/v1/createTokenRequest');
    }
  }

  final response = await http.post(url, body: tokenParamsMap);
  return jsonDecode(response.body) as Map<String, dynamic>;
}
```

- **Android:** To connect to a local server running on a computer from an Android device, you can redirect the port on your device to the port the application is hosted on on your computer. For example, if you want to connect to a local server running at `localhost:3000` but connect from Android from `localhost:80` Run `adb reverse tcp:80 tcp:3000`.
- **iOS:** To connect to a local server running on a computer using `http` on iOS for debugging, you will need to explicitly enable this in your `Info.plist` file, by following [Transport security has blocked a cleartext HTTP](https://stackoverflow.com/a/30751597/7365866). To allow devices to connect from the IP address of your device, you need your server to listen on `0.0.0.0` instead of `127.0.0.1`.

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

### Symmetric Encryption

When a key is provided to the library, the `data` attribute of all messages is encrypted and decrypted automatically using that key. The secret key is never transmitted to Ably. See https://www.ably.com/docs/realtime/encryption.

1. Create a key by calling `ably.Crypto.generateRandomKey()` (or retrieve one from your server using your own secure API). The same key needs to be used to encrypt and decrypt the messages.
2. Create a `CipherParams` instance by passing a key to `final cipherParams = await ably.Crypto.getDefaultParams(key: key);` - the key can be a Base64-encoded `String`, or a `Uint8List`
3. Create a `RealtimeChannelOptions` or `RestChannelOptions` from this key: e.g. `final channelOptions = ably.RealtimeChannelOptions(cipher: cipherParams);`. Alternatively, if you are only setting CipherParams on ChannelOptions, you could skip creating the `CipherParams` instance: `ably.RestChannelOptions.withCipherKey(cipherKey)` or `ably.RealtimeChannelOptions.withCipherKey(cipherKey)`.
4. Set these options on your channel: `realtimeClient.channels.get(channelName).setOptions(channelOptions);`
5. Use your channel as normal, such as by publishing messages or subscribing for messages.

Overall, it would like this:
```dart
final key = ...; // from your server, from password or create random
final cipherParams = ably.Crypto.getDefaultParams(key: key);
final channelOptions = ably.RealtimeChannelOptions(cipherParams: cipherParams);
final channel = realtime.channels.get("your channel name");
await channel.setOptions(channelOptions);
```

Take a look at [`encrypted_message_service.dart`](example/lib/encrypted_messaging_service.dart) for an example of how to implement end-to-end encrypted messages over Ably. There are several options to choose from when you have decided to your encrypt your messages.

### Push Notifications

See [PushNotifications.md](PushNotifications.md) for detailed information on using PN with this plugin.

## Resources

- [Quickstart Guide](https://www.ably.com/docs/quick-start-guide?lang=flutter)
- [Introducing the Ably Flutter plugin](https://www.ably.com/blog/ably-flutter-plugin) by [Srushtika](https://github.com/Srushtika) (Developer Advocate)
- [Building a Realtime Cryptocurrency App with Flutter](https://www.ably.com/tutorials/realtime-cryptocurrency-app-flutter) by [pr-Mais](https://github.com/pr-Mais) and [escamoteur](https://github.com/escamoteur)
- [Building realtime apps with Flutter and WebSockets: client-side considerations](https://www.ably.com/topic/websockets-flutter)

## Requirements

### Flutter

Flutter 2.5.0 or higher is required.

### iOS

iOS 10 or newer.

### Android

API Level 19 (Android 4.4, KitKat) or newer.

_This project uses Java 8 language features, utilizing [Desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring)
to support lower versions of the Android runtime (i.e. API Levels prior to 24)_

If your project needs support for SDK Version lower than 24, Android Gradle Plugin 4.0.0+ must be used.
You might also need to upgrade [gradle distribution](https://developer.android.com/studio/releases/gradle-plugin#updating-plugin) accordingly.

## Updating to a newer version

When increasing the version of `ably_flutter` in your `pubspec.yaml`, there may be breaking changes. To migrate code across these breaking changes, follow the [updating / migration guide](UPDATING.md).

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
Future<void>.delayed(Duration.zero, () {
    subscriptionToBeCancelled.cancel();
});
```

## Contributing

For guidance on how to contribute to this project, see [CONTRIBUTING.md](CONTRIBUTING.md).
