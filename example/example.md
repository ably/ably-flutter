# Ably-Flutter examples

## Authentication

### Authenticate using [key authentication](https://ably.com/docs/core-features/authentication/#basic-authentication)

```dart
// Create an instance of ClientOptions with Ably key
final clientOptions = ably.ClientOptions(key: '<KEY>');

// Use ClientOptions to create realtime or rest instance
ably.Realtime realtime = ably.Realtime(options: clientOptions);
ably.Rest rest = ably.Rest(options: clientOptions);
```

### Authenticate using [token authentication](https://ably.com/docs/core-features/authentication/#token-authentication)

#### Token only

```dart
// Create an instance of ClientOptions with Ably token
ably.ClientOptions clientOptions = ably.ClientOptions(key: '<TOKEN>');

// Use ClientOptions to create realtime or rest instance
ably.Realtime realtime = ably.Realtime(options: clientOptions);
ably.Rest rest = ably.Rest(options: clientOptions);
```

#### Token with TokenCallback

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

// Use ClientOptions to create realtime or rest instance
ably.Realtime realtime = ably.Realtime(options: clientOptions);
ably.Rest rest = ably.Rest(options: clientOptions);
```

## Using the Realtime API

### Realtime instance

#### Create instance of Realtime API

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

### Realtime channel

#### Create instance of realtime channel

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

#### Listen for all realtime presence messages

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

## Using the REST API

### Rest instance

#### Create instance of REST API

```dart
ably.Rest rest = ably.Rest(options: clientOptions);
```

#### Read Rest time

```dart
DateTime time = rest.time()
```

### Rest channel

#### Create instance of Rest channel

```dart
ably.RestChannel channel = rest.channels.get('channel-name');
```

### Rest channel messages

#### Publish single message on Rest channel

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

#### Publish multiple messages on Rest channel

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

### Rest channel history

#### Read Rest channel history

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

### Rest presence

#### Get Rest presence

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

#### Read Rest presence history

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

## PaginatedResult handling

### Get items on current page

```dart
// Example PaginatedResult returned from channel history
ably.PaginatedResult<ably.Message> paginatedResult = await channel.history(params);

// Get list of items from result
List<ably.Message> items = paginatedResult.items;
```

### Get next page if available

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

## Encryption

### Create CipherParams

```dart
String key = 'base64EncodedKey'; // Can also be an UInt8List
CipherParams cipherParams = ably.Crypto.getDefaultParams(key: key);
```

### Setup encryption on a channel

```dart
// For realtime
RealtimeChannelOptions realtimeChannelOptions = ably.RealtimeChannelOptions(cipherParams: cipherParams);
RealtimeChannel channel = realtime.channels.get("channel-name");
channel.setOptions(realtimeChannelOptions)

// For rest
RestChannelOptions restChannelOptions = ably.RestChannelOptions(cipherParams: cipherParams);
RestChannel channel = rest.channels.get("channel-name");
channel.setOptions(restChannelOptions)
```
