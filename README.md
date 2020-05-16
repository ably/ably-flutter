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

## Contributing

We have some [Developer Notes](DeveloperNotes.md), but we're still learning too so they'll only help you so far, in fact there's probably a lot you can teach us!

Your pull requests are welcome but please keep them manageable and focussed.
Equally your input on any pull requests we have in flight at any given time is invaluable to us, so please get involved.

Thanks! :grin:


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

##### Create an Ably instance
```dart
final ably.Ably ablyPlugin = ably.Ably();
```

##### create a ClientOptions
```dart
final clientOptions = ably.ClientOptions.fromKey("<YOUR APP KEY>");
clientOptions.environment = 'sandbox';
clientOptions.logLevel = ably.LogLevel.verbose;
```

##### Rest API

```dart
ably.Rest rest = await ablyPlugin.createRest(options: clientOptions);
```

Getting a channel instance
```dart
ably.RestChannel channel = rest.channels.get('test');
```

Publish rest messages

```dart
//passing both name and data
await channel.publish(name: "Hello", data: "Ably");
//passing just name
await channel.publish(name: "Hello");
//passing just data
await channel.publish(data: "Ably");
//publishing an empty message
await channel.publish();
```

##### Realtime API

```dart
ably.Realtime realtime = await ablyPlugin.createRealtime(options: clientOptions);
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

Connect and disconnect to a realtime instance
```dart
realtime.connect();     //connect to realtime
realtime.disconnect();  //disconnect from realtime
```
