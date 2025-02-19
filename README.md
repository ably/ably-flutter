# Ably Flutter Plugin

[![https://pub.dev/packages/ably_flutter](https://img.shields.io/pub/v/ably_flutter)](https://pub.dev/packages/ably_flutter)
[![.github/workflows/check.yaml](https://github.com/ably/ably-flutter/actions/workflows/check.yaml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/check.yaml)
[![.github/workflows/docs.yml](https://github.com/ably/ably-flutter/actions/workflows/docs.yml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/docs.yml)
[![.github/workflows/flutter_integration.yaml](https://github.com/ably/ably-flutter/actions/workflows/flutter_integration.yaml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/flutter_integration.yaml)
[![.github/workflows/flutter_example_app.yaml](https://github.com/ably/ably-flutter/actions/workflows/flutter_example_app.yaml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/flutter_example_app.yaml)
[![Features](https://github.com/ably/ably-flutter/actions/workflows/features.yml/badge.svg)](https://github.com/ably/ably-flutter/actions/workflows/features.yml)

_[Ably](https://ably.com) is the platform that powers synchronized digital experiences in realtime. Whether attending an event in a virtual venue, receiving realtime financial information, or monitoring live car performance data – consumers simply expect realtime digital experiences as standard. Ably provides a suite of APIs to build, extend, and deliver powerful digital experiences in realtime for more than 250 million devices across 80 countries each month. Organizations like Bloomberg, HubSpot, Verizon, and Hopin depend on Ably’s platform to offload the growing complexity of business-critical realtime data synchronization at global scale. For more information, see the [Ably documentation](https://ably.com/documentation)._

## Supported platforms

- Android
- iOS
- Push notifications, [check support section](#push-notifications)

## Requirements

- Flutter 2.5.0 or higher
- iOS 10 or newer
- Android API Level 19 (Android 4.4, KitKat) or newer

This project uses Java 8 language features, utilizing [Desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring)
to support lower versions of the Android runtime (i.e. API Levels prior to 24).

If your project needs support for SDK Version lower than 24, Android Gradle Plugin 4.0.0+ must be used.
You might also need to upgrade [gradle distribution](https://developer.android.com/studio/releases/gradle-plugin#updating-plugin) accordingly.

## Installation

### Specify Dependency

In `pubspec.yaml` file:

```yaml
dependencies:
  ably_flutter: ^1.2.37
```

### Import the package

```dart
import 'package:ably_flutter/ably_flutter.dart' as ably;
```

### Updating to a newer version

When increasing the version of `ably_flutter` in your `pubspec.yaml`, if there are breaking changes, follow the [updating / migration guide](UPDATING.md).

## Usage

Please check [demo code snippets](example/example.md) and [flutter example app](./CONTRIBUTING.md#running-the-example) for more detailed usage.

### Authentication

#### Authentication using API Key

```dart
// Create an instance of ClientOptions with Ably key
final clientOptions = ably.ClientOptions(key: '<KEY>');

// Use ClientOptions to create Realtime or REST instance
ably.Realtime realtime = ably.Realtime(options: clientOptions);
ably.Rest rest = ably.Rest(options: clientOptions);
```

Also see docs:
[Auth and Security: Basic authentication](https://ably.com/docs/core-features/authentication/#basic-authentication)

#### Token Authentication

Supplying a `TokenCallback`:

```dart
// Create an instance of ClientOptions with Ably token and authCallback
ably.ClientOptions clientOptions = ably.ClientOptions(
    key: '<TOKEN>', 
    clientId: '<CLIENT>', // Optional
    authCallback: (ably.TokenParams tokenParams) async {
        // `createTokenRequest` should be implemented to communicate with user server
        ably.TokenRequest tokenRequest = await createTokenRequest(tokenParams);
        // `authCallback` has to return an instance of TokenRequest
        return tokenRequest;
    }
);

// Use ClientOptions to create Realtime or REST instance
ably.Realtime realtime = ably.Realtime(options: clientOptions);
ably.Rest rest = ably.Rest(options: clientOptions);
```

Also see docs:
[Auth and Security: Token authentication](https://ably.com/docs/core-features/authentication/#token-authentication)

### Realtime instance

#### Create an instance of the Realtime Client

```dart
ably.Realtime realtime = ably.Realtime(options: clientOptions);
```

#### Read Realtime time

```dart
DateTime time = realtime.time()
```

### Connection state

#### Listen for all connection state events

```dart
realtime.connection
    .on()
    .listen((ably.ConnectionStateChange stateChange) async {
        // Handle connection state change events
    });
```

#### Listen for particular connection state event

```dart
realtime.connection
    .on(ably.ConnectionEvent.connected) // Any type of `ConnectionEvent` can be specified
    .listen((ably.ConnectionStateChange stateChange) async {
        // Handle connection state change events
    });
```

#### Retrieve connection id, state etc
```dart
String connectionId = realtime.connection.id;
ConnectionState state = realtime.connection.state;
String recoveryKey = await realtime.connection.createRecoveryKey(); // https://ably.com/docs/connect/states?q=recovery#connection-state-recover-options
```

### Realtime channel

#### Create instance of Realtime channel

```dart
ably.RealtimeChannel channel = realtime.channels.get('channel-name');
```

#### Attach and detach from channel

```dart
await channel.attach()
await channel.detach()
```

### Channel state

#### Listen for all channel state events

```dart
channel
    .on()
    .listen((ably.ChannelStateChange stateChange) async {
        // Handle channel state change events
    });
```

#### Listen for particular channel state event

```dart
channel
    .on(ably.ChannelEvent.failed) // Any type of `ConnectionEvent` can be specified
    .listen((ably.ChannelStateChange stateChange) async {
        // Handle channel state change events
    });
```

### Channel messages

#### Listen for all messages

```dart
StreamSubscription<ably.Message> subscription = 
    channel
        .subscribe()
        .listen((ably.Message message) {
            // Handle channel message
        });
```

#### Listen for message with selected name

```dart
StreamSubscription<ably.Message> subscription = 
    channel
        .subscribe(name: 'event1')
        .listen((ably.Message message) {
            // Handle channel messages with name 'event1'
        });
```

#### Listen for messages with a set of selected names

```dart
StreamSubscription<ably.Message> subscription =
    channel
        .subscribe(names: ['event1', 'event2'])
        .listen((ably.Message message) {
            // Handle channel messages with name 'event1' or `event2`
        });
```

#### Stop listening for messages

```dart
await subscription.cancel()
```

#### Publish single message on channel

```dart
// Publish simple message
await channel.publish(
    name: "event1",
    data: "hello world",
);

// Publish message data as json-encodable object
await channel.publish(
    name: "event1",
    data: {
        "hello": "world",
        "hey": "ably",
    },
);

// Publish message as array of json-encodable objects
await channel.publish(
    name: "event1",
    data: [
        {
        "hello": {
            "world": true,
        },
        "ably": {
            "serious": "realtime",
        },
    ],
);

// Publish message as an `ably.Message` object
await channel.publish(
    message: ably.Message(
        name: "event1",
        data: {
            "hello": "world",
        }
    ),
);
```

#### Publish multiple messages on channel

```dart
await channel.publish(
    messages: [
        ably.Message(
            name: "event1",
            data: {
                "hello": "world",
            }
        ),
        ably.Message(
            name: "event1",
            data: {
                "hello": "ably",
            }
        ),
    ],
);
```

### Channel history

#### Read channel history

```dart
// Get channel history with default parameters
ably.PaginatedResult<ably.Message> history = await channel.history()

// Get channel history with custom parameters
ably.PaginatedResult<ably.Message> filteredHistory = await channel.history(
    ably.RealtimeHistoryParams(
        direction: 'forwards',
        limit: 10,
    )
)
```

### Realtime presence

#### Enter Realtime presence

```dart
// Enter using client ID from `ClientOptions`
await channel.presence.enter();

// Enter using client ID from `ClientOptions` with additional data
await channel.presence.enter("hello");
await channel.presence.enter([1, 2, 3]);
await channel.presence.enter({"key": "value"});

// Enter with specified client ID
await channel.presence.enterClient("user1");

// Enter with specified client ID and additional data
await channel.presence.enterClient("user1", "hello");
await channel.presence.enterClient("user1", [1, 2, 3]);
await channel.presence.enterClient("user1", {"key": "value"});
```

#### Update Realtime presence

```dart
// Update using client ID from `ClientOptions`
await channel.presence.update();

// Update using client ID from `ClientOptions` with additional data
await channel.presence.update("hello");
await channel.presence.update([1, 2, 3]);
await channel.presence.update({"key": "value"});

// Update with specified client ID
await channel.presence.updateClient("user1");

// Update with specified client ID and additional data
await channel.presence.updateClient("user1", "hello");
await channel.presence.updateClient("user1", [1, 2, 3]);
await channel.presence.updateClient("user1", {"key": "value"});
```

#### Leave Realtime presence

```dart
// Leave using client ID from `ClientOptions`
await channel.presence.leave();

// Leave using client ID from `ClientOptions` with additional data
await channel.presence.leave("hello");
await channel.presence.leave([1, 2, 3]);
await channel.presence.leave({"key": "value"});

// Leave with specified client ID
await channel.presence.leaveClient("user1");

// Leave with specified client ID and additional data
await channel.presence.leaveClient("user1", "hello");
await channel.presence.leaveClient("user1", [1, 2, 3]);
await channel.presence.leaveClient("user1", {"key": "value"});
```

#### Get Realtime presence

```dart

// Get all presence messages
List<ably.PresenceMessage> presenceMessages = await channel.presence.get();

// Get presence messages with specific Client ID
presenceMessages = await channel.presence.get(
    ably.RealtimePresenceParams(
        clientId: 'clientId',
    ),
);

// Get presence messages with specific Connection ID
presenceMessages = await channel.presence.get(
    ably.RealtimePresenceParams(
        connectionId: 'connectionId',
    ),
);
```

#### Read Realtime presence history

```dart
// Get presence history with default parameters
ably.PaginatedResult<ably.PresenceMessage> history = await channel.presence.history()

// Get presence history with custom parameters
ably.PaginatedResult<ably.PresenceMessage> filteredHistory = await channel.presence.history(
    ably.RealtimeHistoryParams(
        direction: 'forwards',
        limit: 10,
    )
)
```

#### Listen for all Realtime presence messages

```dart
StreamSubscription<ably.PresenceMessage> subscription =
    channel
        .presence
        .subscribe()
        .listen((presenceMessage) {
            // Handle presence message
        },
);
```

#### Listen for a particular presence message

```dart
StreamSubscription<ably.PresenceMessage> subscription =
    channel
        .presence
        .subscribe(action: PresenceAction.enter)
        .listen((presenceMessage) {
            // Handle `enter` presence message
        },
);
```

#### Listen for a set of particular presence messages

```dart
StreamSubscription<ably.PresenceMessage> subscription =
    channel
        .presence
        .subscribe(actions: [
            PresenceAction.enter,
            PresenceAction.update,
        ])
        .listen((presenceMessage) {
            // Handle `enter` and `update` presence message
        },
);
```

### REST instance

#### Create an instance of the REST Client

```dart
ably.Rest rest = ably.Rest(options: clientOptions);
```

#### Read REST time

```dart
DateTime time = rest.time()
```

### REST channel

#### Create instance of REST channel

```dart
ably.RestChannel channel = rest.channels.get('channel-name');
```

### REST channel messages

#### Publish single message on REST channel

```dart
// Publish simple message
await channel.publish(
    name: "event1",
    data: "hello world",
);

// Publish message data as json-encodable object
await channel.publish(
    name: "event1",
    data: {
        "hello": "world",
        "hey": "ably",
    },
);

// Publish message as array of json-encodable objects
await channel.publish(
    name: "event1",
    data: [
        {
        "hello": {
            "world": true,
        },
        "ably": {
            "serious": "realtime",
        },
    ],
);

// Publish message as an `ably.Message` object
await channel.publish(
    message: ably.Message(
        name: "event1",
        data: {
            "hello": "world",
        }
    ),
);
```

#### Publish multiple messages on REST channel

```dart
await channel.publish(
    messages: [
        ably.Message(
            name: "event1",
            data: {
                "hello": "world",
            }
        ),
        ably.Message(
            name: "event1",
            data: {
                "hello": "ably",
            }
        ),
    ],
);
```

### REST channel history

#### Read REST channel history

```dart
// Get channel history with default parameters
ably.PaginatedResult<ably.Message> history = await channel.history()

// Get channel history with custom parameters
ably.PaginatedResult<ably.Message> filteredHistory = await channel.history(
    ably.RestHistoryParams(
        direction: 'forwards',
        limit: 10,
    )
)
```

### REST presence

#### Get REST presence

```dart
// Get all presence messages
List<ably.PresenceMessage> presenceMessages = await channel.presence.get();

// Get presence messages with specific Client ID
presenceMessages = await channel.presence.get(
    ably.RestPresenceParams(
        clientId: 'clientId',
    ),
);

// Get presence messages with specific Connection ID
presenceMessages = await channel.presence.get(
    ably.RestPresenceParams(
        connectionId: 'connectionId',
    ),
);
```

#### Read REST presence history

```dart
// Get presence history with default parameters
ably.PaginatedResult<ably.PresenceMessage> history = await channel.presence.history();

// Get presence history with custom parameters
ably.PaginatedResult<ably.PresenceMessage> filteredHistory = await channel.presence.history(
    ably.RestHistoryParams(
        direction: 'forwards',
        limit: 10,
    )
);
```

### PaginatedResult handling

#### Get items on current page

```dart
// Example PaginatedResult returned from channel history
ably.PaginatedResult<ably.Message> paginatedResult = await channel.history(params);

// Get list of items from result
List<ably.Message> items = paginatedResult.items;
```

#### Get next page if available

```dart
// Example PaginatedResult returned from channel history
ably.PaginatedResult<ably.Message> paginatedResult = await channel.history(params);

// Check if next page is available
bool hasNextPage = paginatedResult.hasNext();

// Fetch next page if it's available
if (hasNextPage) {    
  paginatedResult = await paginatedResult.next();
}
```

### Encryption

#### Create CipherParams

```dart
String key = 'base64EncodedKey'; // Can also be an UInt8List
CipherParams cipherParams = ably.Crypto.getDefaultParams(key: key);
```

#### Setup encryption on a channel

```dart
// For Realtime
RealtimeChannelOptions realtimeChannelOptions = ably.RealtimeChannelOptions(cipherParams: cipherParams);
RealtimeChannel channel = realtime.channels.get("channel-name");
channel.setOptions(realtimeChannelOptions)

// For REST
RestChannelOptions restChannelOptions = ably.RestChannelOptions(cipherParams: cipherParams);
RestChannel channel = rest.channels.get("channel-name");
channel.setOptions(restChannelOptions)
```

## Known limitations

### Missing features

Features that we do not currently support, but we do plan to add in the future:

- Ably token generation ([#105](https://github.com/ably/ably-flutter/issues/105))
- REST and Realtime Stats ([#106](https://github.com/ably/ably-flutter/issues/106))
- Push Notifications Admin ([#109](https://github.com/ably/ably-flutter/issues/109))

### RTE6a compliance

Using the Streams based approach doesn't fully conform with
[RTE6a](https://docs.ably.com/client-lib-development-guide/features/#RTE6a)
from our
[client library features specification](https://docs.ably.com/client-lib-development-guide/features/).

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

#### The Workaround - Cancelling using delay

Instead of `await subscriptionToBeCancelled.cancel();`, use

```dart
Future<void>.delayed(Duration.zero, () {
    subscriptionToBeCancelled.cancel();
});
```

## Push Notifications

By default, push-related components in the sample app won't work on Android, because of a dummy [google-services.json](example/android/app/src/google-services.json) file. In order to use push messaging features of Ably SDK, additional FCM/APNS configuration is required.

See [PushNotifications.md](PushNotifications.md) for detailed information on getting PN working with the example app.

## Feature support

See Ably [feature support matrix](https://ably.com/download/sdk-feature-support-matrix) for a list of features supported by this SDK.

## Support, feedback and troubleshooting

Please visit [ably.com/support](https://ably.com/support) for access to our knowledge base and to ask for any assistance.

To see what has changed in recent versions, see the [CHANGELOG](CHANGELOG.md).

## Contributing

For guidance on how to contribute to this project, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Resources

- [Quickstart Guide](https://www.ably.com/docs/quick-start-guide?lang=flutter)
- [Introducing the Ably Flutter plugin](https://www.ably.com/blog/ably-flutter-plugin) by [Srushtika](https://github.com/Srushtika) (Developer Advocate)
- [Building a Realtime Cryptocurrency App with Flutter](https://www.ably.com/tutorials/realtime-cryptocurrency-app-flutter) by [pr-Mais](https://github.com/pr-Mais) and [escamoteur](https://github.com/escamoteur)
- [Building realtime apps with Flutter and WebSockets: client-side considerations](https://www.ably.com/topic/websockets-flutter)
