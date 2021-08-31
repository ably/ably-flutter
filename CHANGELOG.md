# Changelog

## [1.2.2-preview.1](https://github.com/ably/ably-flutter/tree/v1.2.2-preview.1)

This is a preview release of v1.2.2, which adds support for push notifications, including device activation with Ably (including device registration with APNs / FCM), subscribing devices for push notifications. Check out the dedicated documentation (`PushNotifications.md`) and the example app (`push_notification_service.dart`) for more information.

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.1...v1.2.2-preview.1)

**Implemented enhancements:**

- Push Notifications Device Registration \(activation\) and device subscription [\#107](https://github.com/ably/ably-flutter/issues/107)

**Merged pull requests:**

- Add documentation for token authentication [\#155](https://github.com/ably/ably-flutter/pull/155) ([ben-xD](https://github.com/ben-xD))
- Push notifications \(activation and subscription\) [\#140](https://github.com/ably/ably-flutter/pull/140) ([ben-xD](https://github.com/ben-xD))

## [v1.2.1](https://github.com/ably/ably-flutter/tree/v1.2.1)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.0...v1.2.1)

**Implemented enhancements:**

- Migrate to null safety [\#82](https://github.com/ably/ably-flutter/issues/82)

**Closed issues:**

- Investigate libraries that can help leverage our push implementation [\#142](https://github.com/ably/ably-flutter/issues/142)
- Could not find method coreLibraryDesugaring\(\) for arguments [\#130](https://github.com/ably/ably-flutter/issues/130)
- Create code snippets for homepage \(flutter\) [\#124](https://github.com/ably/ably-flutter/issues/124)
- Make this SDK ready for the first non-preview release  [\#102](https://github.com/ably/ably-flutter/issues/102)
- Activate and getting Push Notifications [\#54](https://github.com/ably/ably-flutter/issues/54)

**Merged pull requests:**

- Bump ws from 5.2.2 to 5.2.3 in /example/test\_harness [\#145](https://github.com/ably/ably-flutter/pull/145) ([dependabot[bot]](https://github.com/apps/dependabot))
- Skip 1 failing test, fix 1 failing test and schedule tests on main twice a day [\#144](https://github.com/ably/ably-flutter/pull/144) ([ben-xD](https://github.com/ben-xD))
- Refactor large files into 1 file per class [\#138](https://github.com/ably/ably-flutter/pull/138) ([ben-xD](https://github.com/ben-xD))
- Add instructions for M1 macs and fixing ruby fatal error for example apps [\#137](https://github.com/ably/ably-flutter/pull/137) ([ben-xD](https://github.com/ben-xD))
- Migrate to null-safety [\#136](https://github.com/ably/ably-flutter/pull/136) ([tiholic](https://github.com/tiholic))

## [v1.2.0](https://github.com/ably/ably-flutter/tree/v1.2.0)

[Full Changelog](https://github.com/ably/ably-flutter/compare/1.2.0-preview.2...v1.2.0)

**Merged pull requests:**

- Add support message extras and its extensions \[TM2i\] [\#123](https://github.com/ably/ably-flutter/pull/123) ([tiholic](https://github.com/tiholic)), fixing [\#11](https://github.com/ably/ably-flutter/issues/11)
- add docs for rest and realtime presence [\#114](https://github.com/ably/ably-flutter/pull/114) ([tiholic](https://github.com/tiholic))
- REST - Channels & publishing messages [\#45](https://github.com/ably/ably-flutter/pull/45) ([tiholic](https://github.com/tiholic))

## [1.2.0-preview.2](https://github.com/ably/ably-flutter/tree/1.2.0-preview.2)

[Full Changelog](https://github.com/ably/ably-flutter/compare/1.2.0-preview.1...1.2.0-preview.2)

**Implemented enhancements:**

- Presence subscription example [\#53](https://github.com/ably/ably-flutter/issues/53)
- typed Message\#data [\#35](https://github.com/ably/ably-flutter/issues/35)

**Fixed bugs:**

- compilation error on iOS [\#112](https://github.com/ably/ably-flutter/issues/112)

**Merged pull requests:**

- Fix iOS issue with token details auth [\#115](https://github.com/ably/ably-flutter/pull/115) ([tiholic](https://github.com/tiholic))
- Add docs workflow [\#97](https://github.com/ably/ably-flutter/pull/97) ([QuintinWillison](https://github.com/QuintinWillison))
- Realtime Presence [\#81](https://github.com/ably/ably-flutter/pull/81) ([tiholic](https://github.com/tiholic))
- Feature/rest presence history [\#70](https://github.com/ably/ably-flutter/pull/70) ([tiholic](https://github.com/tiholic))
- Feature/docstrings [\#69](https://github.com/ably/ably-flutter/pull/69) ([tiholic](https://github.com/tiholic))
- Rest Channel Presence\#get [\#55](https://github.com/ably/ably-flutter/pull/55) ([tiholic](https://github.com/tiholic))

## [1.2.0-preview.1](https://github.com/ably/ably-flutter/tree/1.2.0-preview.1)

[Full Changelog](https://github.com/ably/ably-flutter/compare/1.0.0+dev.2...1.2.0-preview.1)

With this release we are conforming our version numbering to match that used in our other client libraries.
This reflects the fact that this plugin is heading towards compliance with version 1.2 of our
[Features Specification](https://docs.ably.io/client-lib-development-guide/features/), also aligning with the
underlying implementations of
[ably-cocoa](https://github.com/ably/ably-cocoa)
and
[ably-java](https://github.com/ably/ably-java).

**Fixed bugs:**

- Unhandled TimeoutException error being thrown occassionally [\#72](https://github.com/ably/ably-flutter/issues/72)

**Closed issues:**

- native dart implementation [\#76](https://github.com/ably/ably-flutter/issues/76)
- Improve our "pub points" score on pub.dev [\#65](https://github.com/ably/ably-flutter/issues/65)
- Ably Flutter - Error building for android: target SDK less than 24 [\#25](https://github.com/ably/ably-flutter/issues/25)

**Merged pull requests:**

- Conform workflow triggers [\#91](https://github.com/ably/ably-flutter/pull/91) ([QuintinWillison](https://github.com/QuintinWillison))
- Rename Package to remove the _plugin suffix [\#90](https://github.com/ably/ably-flutter/pull/90) ([QuintinWillison](https://github.com/QuintinWillison))
- Stage 1.1 Integration [\#88](https://github.com/ably/ably-flutter/pull/88) ([QuintinWillison](https://github.com/QuintinWillison))
- Readme Improvements [\#79](https://github.com/ably/ably-flutter/pull/79) ([QuintinWillison](https://github.com/QuintinWillison))
- Add maintainers file [\#78](https://github.com/ably/ably-flutter/pull/78) ([niksilver](https://github.com/niksilver))
- Remove experimental warning [\#77](https://github.com/ably/ably-flutter/pull/77) ([QuintinWillison](https://github.com/QuintinWillison))
- Android | reduce minSdkVersion to 19 [\#75](https://github.com/ably/ably-flutter/pull/75) ([tiholic](https://github.com/tiholic))
- Feature/rest history integration tests [\#68](https://github.com/ably/ably-flutter/pull/68) ([tiholic](https://github.com/tiholic))
- Feature/lint dart [\#67](https://github.com/ably/ably-flutter/pull/67) ([tiholic](https://github.com/tiholic))
- Realtime Channel history [\#52](https://github.com/ably/ably-flutter/pull/52) ([tiholic](https://github.com/tiholic))
- Channel history & Paginated Result API for Rest [\#48](https://github.com/ably/ably-flutter/pull/48) ([tiholic](https://github.com/tiholic))

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
