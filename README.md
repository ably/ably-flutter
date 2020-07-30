# Ably Flutter Plugin

A
[Flutter](https://flutter.dev/)
plugin wrapping the
[ably-cocoa](https://github.com/ably/ably-cocoa) (iOS)
and
[ably-java](https://github.com/ably/ably-java) (Android)
client library SDKs for [Ably](https://ably.io/), the realtime data delivery platform.

Ably provides the best infrastructure and APIs to power realtime experiences at scale, delivering billions of realtime messages everyday to millions of end users.
We handle the complexity of realtime messaging so you can focus on your code.

## :construction: Experimental! :construction:

We're busy working on this repository at the moment and we're doing that work in the public domain so that you can watch or
[contribute](#contributing).

Get in touch if you are interested in using Ably from your Flutter apps.
We have our own ideas for how we build out this plugin but we would love to hear from you if there's a feature or capability in particular that you think we should prioritise.

Create a public
[Issue](https://github.com/ably/ably-flutter/issues)
or visit our
[Support and Help](https://www.ably.io/support)
site to discuss privately.

## Running the example

* Clone the repo
* cd to `example` folder
* run `flutter packages get` to install dependencies
* `flutter run` will start the application on connected android / iOS device


## Using the Realtime API

##### Import the package

```dart
import 'package:ably_flutter_plugin/ably.dart' as ably;
```

##### create a ClientOptions

```dart
final clientOptions = ably.ClientOptions.fromKey("<YOUR APP KEY>");
clientOptions.logLevel = ably.LogLevel.verbose; //optional
```

##### Rest API

```dart
ably.Rest rest = ably.Rest(options: clientOptions);
```

Getting a channel instance

```dart
ably.RestChannel channel = rest.channels.get('test');
```

Publish rest messages

```dart
void publishMessages() async {
    //passing both name and data
    await channel.publish(name: "Hello", data: "Ably");
    //passing just name
    await channel.publish(name: "Hello");
    //passing just data
    await channel.publish(data: "Ably");
    //publishing an empty message
    await channel.publish();
}

publishMessages();
```

##### Realtime API

```dart
ably.Realtime realtime = ably.Realtime(options: clientOptions);
```

Listen to connection state change event

```dart
realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
  print('Realtime connection state changed: ${stateChange.event}');
  setState(() { _realtimeConnectionState = stateChange.current; });
});
```

Listening to a particular event: `connected`

```dart
realtime.connection.on(ably.ConnectionEvent.connected).listen((ably.ConnectionStateChange stateChange) async {
  print('Realtime connection state changed: ${stateChange.event}');
  setState(() { _realtimeConnectionState = stateChange.current; });
});
```

Connect and disconnect to a Realtime instance

```dart
realtime.connect();     //connect to realtime
realtime.disconnect();  //disconnect from realtime
```

Creating a Realtime channel

```dart
ably.RealtimeChannel channel = realtime.channels.get('channel-name');
```

Listening to channel events

```dart
channel.on().listen((ably.ChannelStateChange stateChange){
  print("Channel state changed: ${stateChange.current}");
});
```

Attaching to channel

```dart
await channel.attach();
```

Detaching from channel

```dart
await channel.detach();
```

Subscribing to channel messages

```dart
Stream<ably.Message> messageStream = channel.subscribe();
StreamSubscription<ably.Message> channelMessageSubscription = messageStream.listen((ably.Message message){
  print("New message arrived ${message.data}");
});
```

_use `channel.subscribe(name: "event1")` or `channel.subscribe(names: ["event1", "event2"])` to listen to specific named messages_

UnSubscribing from channel messages

```dart
await channelMessageSubscription.cancel();
```

Publishing channel messages

```dart
//publish name and data
await channel.publish(name: "event1", data: "hello world");
await channel.publish(name: "event1", data: {"hello": "world", "hey": "ably"});
await channel.publish(name: "event1", data: [{"hello": {"great": "world"}, "ably": {"serious": true, "realtime": true}, "key3": null}, "string4", "string5"]);

//publish single message
await channel.publish(message: ably.Message()..name = "event1"..data = {"hello": "world"});

//publish multiple messages
await channel.publish(messages: [
  ably.Message()..name="event1"..data = {"hello": "ably"},
  ably.Message()..name="event1"..data = {"hello": "world"}
]);
```

## Caveats

#### RTE6a compliance

Using Streams based approach doesn't fully conform with [RTE6a](https://docs.ably.io/client-lib-development-guide/features/#RTE6a) from the spec.

##### Problem

```dart
StreamSubscription subscriptionToBeCancelled;

//Listener registered 1st
realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
  if (stateChange.event == ably.ConnectionEvent.connected) {
    await subscriptionToBeCancelled.cancel();       //Cancelling 2nd listener
  }
});

//Listener registered 2nd
subscriptionToBeCancelled = realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
  print('State changed');
});
```

In the example above, 2nd listener is cancelled when 1st listener is notified about the "connected" event.
As per RTE6a, 2nd listener should also be triggered, but it will not be as 2nd listener is registered after 1st listener and  stream subscription is cancelled immediately after first listener is triggered.

This wouldn't have happened if 2nd listener was registered before the 1st.

However, using a neat little trick will fix this.

##### Suggestion - Cancelling using delay

Instead of `await subscriptionToBeCancelled.cancel();`, use

```dart
Future.delayed(Duration.zero, (){
    subscriptionToBeCancelled.cancel();
});
```

## Contributing

We have some [Developer Notes](DeveloperNotes.md), but we're still learning too so they'll only help you so far, in fact there's probably a lot you can teach us!

Your pull requests are welcome but please keep them manageable and focussed.
Equally your input on any pull requests we have in flight at any given time is invaluable to us, so please get involved.

Thanks! :grin:
