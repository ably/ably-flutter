# Changelog

## [1.0.0+dev.2](https://github.com/ably/ably-flutter/tree/1.0.0-dev.2)

Conforming to pub.dev recommendations, following initial upload to the platform.

## [1.0.0+dev.1](https://github.com/ably/ably-flutter/tree/1.0.0-dev.1)

The first, development preview of our Flutter plugin, wrapping our
[iOS Cocoa](https://github.com/ably/ably-cocoa)
and 
[Android](https://github.com/ably/ably-java)
client libraries.

### Supported functionality

- Create a REST or Realtime instance by passing `ClientOptions`:
    - `ClientOptions` can be created by passing an API token (`ClientOptions.fromKey`)
    - `defaultTokenParams`, `authCallback` and `logHandler` are not supported yet
- Get a REST channel and publish messages
- Listen for Realtime connection state changes using a stream subscription
- Listen for Realtime channel state changes using a stream subscription
- Connect and disconnect Realtime channels
- Attach and detach Realtime channels
- Subscribe for messages on a Realtime channel using a stream subscription
- Publishing messages on a Realtime channel

### Merged pull requests:

- iOS podspec tweaks [\#46](https://github.com/ably/ably-flutter/pull/46) ([QuintinWillison](https://github.com/QuintinWillison))
- Drive test example [\#32](https://github.com/ably/ably-flutter/pull/32) ([zoechi](https://github.com/zoechi))
- Manual testing on RTN14 and RTN15 [\#27](https://github.com/ably/ably-flutter/pull/27) ([tiholic](https://github.com/tiholic))
- Fix: iOS hot-restart issue with active listeners [\#26](https://github.com/ably/ably-flutter/pull/26) ([tiholic](https://github.com/tiholic))
- Realtime Publish [\#23](https://github.com/ably/ably-flutter/pull/23) ([tiholic](https://github.com/tiholic))
- Realtime message subscription [\#21](https://github.com/ably/ably-flutter/pull/21) ([tiholic](https://github.com/tiholic))
- Realtime Channel attach, detach and state events [\#20](https://github.com/ably/ably-flutter/pull/20) ([tiholic](https://github.com/tiholic))
- Synchronous API for creating instances and Hot-reload fix [\#18](https://github.com/ably/ably-flutter/pull/18) ([tiholic](https://github.com/tiholic))
- Improve pubspec [\#17](https://github.com/ably/ably-flutter/pull/17) ([QuintinWillison](https://github.com/QuintinWillison))
- re-codec using JSON and Codegen [\#13](https://github.com/ably/ably-flutter/pull/13) ([tiholic](https://github.com/tiholic))
- Pilot implementation for Realtime event based API's - ConnectionStateChange [\#6](https://github.com/ably/ably-flutter/pull/6) ([tiholic](https://github.com/tiholic))
- Feature/platform message encoding [\#5](https://github.com/ably/ably-flutter/pull/5) ([tiholic](https://github.com/tiholic))
- Feature/ios rest [\#4](https://github.com/ably/ably-flutter/pull/4) ([tiholic](https://github.com/tiholic))
- Prepare for publish [\#3](https://github.com/ably/ably-flutter/pull/3) ([QuintinWillison](https://github.com/QuintinWillison))
- Publishing rest messages - android only [\#2](https://github.com/ably/ably-flutter/pull/2) ([tiholic](https://github.com/tiholic))



\* *This Changelog was generated with assistance from the [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
