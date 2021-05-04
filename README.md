# Ably Flutter Plugin

![flutter_integration](https://github.com/ably/ably-flutter/actions/workflows/flutter_integration.yaml/badge.svg)

A
[Flutter](https://flutter.dev/)
plugin wrapping the
[ably-cocoa](https://github.com/ably/ably-cocoa) (iOS)
and
[ably-java](https://github.com/ably/ably-java) (Android)
client library SDKs for [Ably](https://ably.io/), the realtime data delivery platform.

Ably provides the best infrastructure and APIs to power realtime experiences at scale, delivering billions of realtime messages everyday to millions of end users.
We handle the complexity of realtime messaging so you can focus on your code.

## Resources

- [Quickstart Guide](https://www.ably.io/documentation/quick-start-guide?lang=flutter)
- [Introducing the Ably Flutter plugin](https://www.ably.io/blog/ably-flutter-plugin) by [Srushtika](https://github.com/Srushtika) (Developer Advocate)
- [Building a Realtime Cryptocurrency App with Flutter](https://www.ably.io/tutorials/realtime-cryptocurrency-app-flutter) by [pr-Mais](https://github.com/pr-Mais) and [escamoteur](https://github.com/escamoteur)
- [Building realtime apps with Flutter and WebSockets: client-side considerations](https://www.ably.io/topic/websockets-flutter)

## Supported Platforms

### iOS

iOS 9 or newer.

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
- run `flutter packages get` to install dependencies
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
clientOptions.logLevel = ably.LogLevel.verbose; // optional
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

    var messages = result.items; //get messages
    var hasNextPage = result.hasNext(); //tells whether there are more results
    if(hasNextPage){    
      result = await result.next();  //fetches next page results
      messages = result.items;
    }
    if(!hasNextPage){
      result = await result.first();  //fetches first page results
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
    // getting channel history, by passing or omitting the optional params
    var result = await channel.presence.get(params);

    var presenceMembers = result.items; //returns PresenceMessages
    var hasNextPage = result.hasNext(); //tells whether there are more results
    if(hasNextPage){
      result = await result.next();  //fetches next page results
      presenceMembers = result.items;
    }
    if(!hasNextPage){
      result = await result.first();  //fetches first page results
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
channel.on().listen((ably.ChannelStateChange stateChange){
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

Subscribing to receive messages received on the channel:

```dart
var messageStream = channel.subscribe();
var channelMessageSubscription = messageStream.listen((ably.Message message){
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
Get realtime history

```dart
void getHistory([ably.RealtimeHistoryParams params]) async {
    var result = await channel.history(params);

    var messages = result.items; //get messages
    var hasNextPage = result.hasNext(); //tells whether there are more results
    if(hasNextPage){    
      result = await result.next();  //fetches next page results
      messages = result.items;
    }
    if(!hasNextPage){
      result = await result.first();  //fetches first page results
      messages = result.items;
    }
}

// history with default params
getHistory();

// sorted and filtered history
getHistory(ably.RealtimeHistoryParams(direction: 'forwards', limit: 10));
```

## Caveats

### RTE6a compliance

Using the Streams based approach doesn't fully conform with
[RTE6a](https://docs.ably.io/client-lib-development-guide/features/#RTE6a)
from our
[client library features specification](https://docs.ably.io/client-lib-development-guide/features/).

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
[RTE6a](https://docs.ably.io/client-lib-development-guide/features/#RTE6a),
the 2nd listener should also be triggered.
It will not be as the 2nd listener was registered after the 1st listener and stream subscription is cancelled immediately after 1st listener is triggered.

This wouldn't have happened if the 2nd listener had been registered before the 1st was.

However, using a neat little workaround will fix this...

#### The Workaround - Cancelling using delay

Instead of `await subscriptionToBeCancelled.cancel();`, use

```dart
Future.delayed(Duration.zero, (){
    subscriptionToBeCancelled.cancel();
});
```

## Contributing

For guidance on how to contribute to this project, see [CONTRIBUTING.md](CONTRIBUTING.md).
