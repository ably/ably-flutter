![Ably Pub/Sub PHP Header](images/flutterSDK-github.png)
[![Pub Version](https://img.shields.io/pub/v/ably_flutter)](https://pub.dev/packages/ably_flutter)
[![License](https://badgen.net/github/license/ably/ably-flutter)](https://github.com/ably/ably-flutter/blob/main/LICENSE)

---

# Ably Pub/Sub Flutter SDK

Build any realtime experience using Ably’s Pub/Sub Flutter SDK. Supported on popular platforms and frameworks, including Android and iOS.

Ably Pub/Sub provides flexible APIs that deliver features such as pub-sub messaging, message history, presence, and push notifications. Utilizing Ably’s realtime messaging platform, applications benefit from its highly performant, reliable, and scalable infrastructure.

Find out more:

* [Ably Pub/Sub docs.](https://ably.com/docs/basics)
* [Ably Pub/Sub examples.](https://ably.com/examples?product=pubsub)

---

## Getting started

Everything you need to get started with Ably:

* [Getting started in Pub/Sub using Flutter.](https://ably.com/docs/getting-started/flutter)
* [SDK Setup for Flutter.](https://ably.com/docs/getting-started/setup?lang=flutter)

---

## Supported platforms

Ably aims to support a wide range of platforms. If you experience any compatibility issues, open an issue in the repository or contact [Ably support](https://ably.com/support).

This SDK supports the following platforms:

| Platform | Support |
|----------|---------|
| Android  | Android 4.4 (API level 19) or newer. Java 8 language features supported via [Desugaring](https://developer.android.com/studio/write/java8-support#library-desugaring). |
| iOS      | iOS 10 or newer |
| Flutter  | Flutter 2.5.0 or higher |

> [!NOTE]
> If your project needs support for SDK Version lower than 24, Android Gradle Plugin 4.0.0+ must be used.
You might also need to upgrade [gradle distribution](https://developer.android.com/studio/releases/gradle-plugin#updating-plugin).
> [!IMPORTANT]
> SDK versions < 1.2.25 will be [deprecated](https://ably.com/docs/platform/deprecate/protocol-v1) from November 1, 2025.

---

## Installation

To get started with your project, install the package:

Add the Ably Flutter package to your project by including it in your `pubspec.yaml` file:

```yaml
dependencies:
  ably_flutter: ^1.2.40
```

Once added to your dependencies, import it in your Dart code:

```dart
import 'package:ably_flutter/ably_flutter.dart' as ably;
```

> [!NOTE]
> When increasing the version of `ably_flutter` in your `pubspec.yaml`, if there are breaking changes, follow the [updating / migration guide](UPDATING.md).

---

## Usage

The following code connects to Ably's realtime messaging service, subscribes to a channel to receive messages, and publishes a test message to that same channel:

```dart
  // Initialize Ably Realtime client
  final clientOptions = ably.ClientOptions(
    key: 'your-ably-api-key',
    clientId: 'me',
  );
  
  final realtimeClient = ably.Realtime(options: clientOptions);
  
  // Wait for connection to be established
  await realtimeClient.connection
      .on(ably.ConnectionEvent.connected)
      .first
      .then((stateChange) {
    print('Connected to Ably');
  });
  
  // Get a reference to the 'test-channel' channel
  final channel = realtimeClient.channels.get('test-channel');
  
  // Subscribe to all messages published to this channel
  channel.subscribe().listen((ably.Message message) {
    print('Received message: ${message.data}');
  });
  
  // Publish a test message to the channel
  await channel.publish(
    name: 'test-event',
    data: 'hello world',
  );
}
```

---


## Releases

The [CHANGELOG.md](./CONTRIBUTING.md) contains details of the latest releases for this SDK. You can also view all Ably releases on [changelog.ably.com](https://changelog.ably.com).

---

## Contributing

Read the [CONTRIBUTING.md](./CONTRIBUTING.md) guidelines to contribute to Ably.

---

## Support, feedback, and troubleshooting

For help or technical support, visit the [Ably Support page](https://ably.com/support) or [GitHub Issues](https://github.com/ably/ably-flutter/issues) for community-reported bugs and discussions.
