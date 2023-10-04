# Changelog

## [1.2.20](https://github.com/ably/ably-flutter/tree/v1.2.20)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.19...v1.2.20)

**Closed issues:**

- \[Android\] Encrypted channels periodically throws `java.util.ConcurrentModificationException` [\#483](https://github.com/ably/ably-flutter/issues/483)
- Replace Cocoa client options calls to `addAgent:version` with `agents` property set [\#448](https://github.com/ably/ably-flutter/issues/448)

## [1.2.19](https://github.com/ably/ably-flutter/tree/v1.2.19)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.18...v1.2.19)

**Closed issues:**

- Ably causes runner to crash in XCode 15 [\#480](https://github.com/ably/ably-flutter/issues/480)
- Does it work for flutter web [\#476](https://github.com/ably/ably-flutter/issues/476)
- Update android decoder for updated clientOptions [\#472](https://github.com/ably/ably-flutter/issues/472)

## [1.2.18](https://github.com/ably/ably-flutter/tree/v1.2.18)

[Full Changelog](https://github.com/ably/ably-flutter/compare/1.2.17...v1.2.18)

**Fixed bugs:**

- Fix java/android custom fallbacks [\#470](https://github.com/ably/ably-flutter/pull/470)

## [1.2.17](https://github.com/ably/ably-flutter/tree/v1.2.17)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.16...v1.2.17)

**Fixed bugs:**

- Realtime connection with authUrl causes crash on iOS [\#465](https://github.com/ably/ably-flutter/issues/465)

## [1.2.16](https://github.com/ably/ably-flutter/tree/v1.2.16)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.15...v1.2.16)

**Implemented enhancements:**

- Added new Auth methods: 'requestToken', 'authorize','createTokenRequest' [\#460](https://github.com/ably/ably-flutter/pull/460)

**Fixed bugs:**

- authHeaders type conversion on Android Plugin is incorrect [\#444](https://github.com/ably/ably-flutter/issues/444)
- iOS \_CastError exception [\#355](https://github.com/ably/ably-flutter/issues/355)

**Closed issues:**

- How to handle when user auth changes? [\#459](https://github
.com/ably/ably-flutter/issues/459)
- Expose `href` from `ErrorInfo` in bubbled exceptions [\#441](https://github.com/ably/ably-flutter/issues/441)
- java.util.HashMap cannot be cast to io.ably.lib.types.Param [\#439](https://github.com/ably/ably-flutter/issues/439)

**Merged pull requests:**

- Add numbers strategy for Gson to prevent changing int to double [\#462](https://github.com/ably/ably-flutter/pull/462) ([Afur](https://github.com/Afur))
- Expose error info in AblyException toString [\#447](https://github.com/ably/ably-flutter/pull/447) ([davyskiba](https://github.com/davyskiba))

## [1.2.15](https://github.com/ably/ably-flutter/tree/v1.2.15)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.14...v1.2.15)

**Fixed bugs:**

- Update `ably-android` dependency to version `1.2.13` or later [\#430](https://github.com/ably/ably-flutter/issues/430), fixed in: Update ably-android to `1.2.15` [\#435](https://github.com/ably/ably-flutter/pull/435) ([JakubJankowski](https://github.com/JakubJankowski))
- Android application got crash on notification receive in killed state using Ably notifications [\#429](https://github.com/ably/ably-flutter/issues/429), fixed in: Main thread fix [\#431](https://github.com/ably/ably-flutter/pull/431) ([ikbalkaya](https://github.com/ikbalkaya)) - reverting the change made under [\#291](https://github.com/ably/ably-flutter/pull/291), released at version `1.2.9`
- Building Example App on Android fails [\#418](https://github.com/ably/ably-flutter/issues/418), fixed in: Fix missing App ID build error in example app [\#421](https://github.com/ably/ably-flutter/pull/421) ([ikurek](https://github.com/ikurek))
- Fix for running didFinishLaunchingWithOptions [\#433](https://github.com/ably/ably-flutter/pull/433) ([Neelansh-ns](https://github.com/Neelansh-ns))

**Closed issues:**

- Deprecated API usage warning for `fallbackHostsUseDefault` [\#416](https://github.com/ably/ably-flutter/issues/416), fixed in: Added lint ignore on deprecated fields [\#423](https://github.com/ably/ably-flutter/pull/423) ([ikurek](https://github.com/ikurek))

## [1.2.14](https://github.com/ably/ably-flutter/tree/v1.2.14)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.13...v1.2.14)

**Implemented enhancements:**

- Add Flutter and/or Dart runtime version to Ably-Agent header, if possible [\#286](https://github.com/ably/ably-flutter/issues/286)
- Throw errors instead of returning null when serialization/ deserialization fails [\#149](https://github.com/ably/ably-flutter/issues/149)
- Custom Transport Parameters \(Params\) [\#108](https://github.com/ably/ably-flutter/issues/108)

**Fixed bugs:**

- Check requirements and update for Flutter 3.0.0 [\#394](https://github.com/ably/ably-flutter/issues/394)
- Upgrade `ably-java` dependency to version 1.2.12 [\#385](https://github.com/ably/ably-flutter/issues/385)
- Swift Compiler Error \(Xcode\): Definition conflicts with previous value [\#347](https://github.com/ably/ably-flutter/issues/347)
- Update errorReason on Realtime.connection [\#120](https://github.com/ably/ably-flutter/issues/120)
- Logging and error handling for ObjC stream listeners [\#399](https://github.com/ably/ably-flutter/pull/399)
- Fixed argument error in Swift implementation of Crypto.generateRandomKey [\#377](https://github.com/ably/ably-flutter/pull/377)
- Fixed iOS push module compilation issue on some versions of XCode [\#373](https://github.com/ably/ably-flutter/pull/373)
- Updated realtime connection to update `errorReason` [\#365](https://github.com/ably/ably-flutter/pull/365)

**Closed issues:**

- Check compatibility with XCode 13 [\#389](https://github.com/ably/ably-flutter/issues/389)
- Document public members of classes [\#380](https://github.com/ably/ably-flutter/issues/380)
- Ably iOS interferes with firebase\_messaging [\#378](https://github.com/ably/ably-flutter/issues/378)
- Sort named constructor parameters alphabetically [\#351](https://github.com/ably/ably-flutter/issues/351)
- Use named arguments for options classes and make all fields private [\#61](https://github.com/ably/ably-flutter/issues/61)

## [1.2.13](https://github.com/ably/ably-flutter/tree/v1.2.13)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.12...v1.2.13)

**Implemented enhancements:**

- Drop support for Android v1 embedding API [\#178](https://github.com/ably/ably-flutter/issues/178)
- Defaults: Generate environment fallbacks [\#47](https://github.com/ably/ably-flutter/issues/47)

**Fixed bugs:**

- Android only - Returning a TokenDetails with 'issued' and 'expires' values in epoch milliseconds throws java error [\#356](https://github.com/ably/ably-flutter/issues/356)
- Fix AblyException assigning 'Message' to 'Code' field [\#349](https://github.com/ably/ably-flutter/issues/349)
- Investigate and fix encryption in sample app [\#334](https://github.com/ably/ably-flutter/issues/334)
-  Execution failed for task ':ably\_flutter:compileDebugJavaWithJavac' while running integration test for android device [\#322](https://github.com/ably/ably-flutter/issues/322)
- Realtime types \(e.g. `RealtimeHistoryParams`\) extending Rest ones \(e.g. `RestHistoryParams`\) can cause problems \(crashes\) [\#241](https://github.com/ably/ably-flutter/issues/241)
- Fix LogHandler \(use it\) [\#238](https://github.com/ably/ably-flutter/issues/238)
- Broken dartdoc link generated from readme [\#110](https://github.com/ably/ably-flutter/issues/110)

**Closed issues:**

- Ably interferes with firebase\_messaging [\#346](https://github.com/ably/ably-flutter/issues/346)
- Missing link to `ApplicationState` in documentation [\#335](https://github.com/ably/ably-flutter/issues/335)
- Write integration tests for realtime channel specs [\#332](https://github.com/ably/ably-flutter/issues/332)
- Consider Simplifying AblyMessage [\#329](https://github.com/ably/ably-flutter/issues/329)
- Upgrade `firebase-messaging` to version 23.0.0 [\#320](https://github.com/ably/ably-flutter/issues/320)
- Example App should be able to build and run without Firebase configured via `google-services.json` [\#318](https://github.com/ably/ably-flutter/issues/318)
- No need for GitHub workflows to explicitly run `flutter pub get` in the `example` folder [\#317](https://github.com/ably/ably-flutter/issues/317)
- Example App should be able to build and run without `ABLY_API_KEY` [\#316](https://github.com/ably/ably-flutter/issues/316)
- resultForDeactivate and resultForActivate are set to null in some situations in Android plugin [\#304](https://github.com/ably/ably-flutter/issues/304)
- Test device activation, subscription, receiving messages and deactivation [\#153](https://github.com/ably/ably-flutter/issues/153)
- Add docstring for "spec" folder [\#29](https://github.com/ably/ably-flutter/issues/29)

## [1.2.12](https://github.com/ably/ably-flutter/tree/v1.2.12)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.11...v1.2.12)

**Fixed bugs:**

- Android: `IllegalStateException` in `Crypto` `CBCCipher`'s `decrypt` method [\#314](https://github.com/ably/ably-flutter/issues/314), fixed by updating to `ably-android` version 1.2.11 [\#319](https://github.com/ably/ably-flutter/pull/319) ([QuintinWillison](https://github.com/QuintinWillison))
- Android: `java.lang.ArrayIndexOutOfBoundsException` thrown by `AblyInstanceStore`'s `setPaginatedResult` method [\#308](https://github.com/ably/ably-flutter/issues/308), fixed in [\#321](https://github.com/ably/ably-flutter/pull/321) ([QuintinWillison](https://github.com/QuintinWillison))
- `ChannelStateChange` property `resumed` should not be nullable [\#297](https://github.com/ably/ably-flutter/issues/297), fixed in [\#313](https://github.com/ably/ably-flutter/pull/313) ([ikurek](https://github.com/ikurek))
- Deprecated Android embedding version [\#311](https://github.com/ably/ably-flutter/issues/311), fixed in [\#312](https://github.com/ably/ably-flutter/pull/312) ([ikurek](https://github.com/ikurek))

**Merged pull requests:**

- Readme enchancements for example app [\#309](https://github.com/ably/ably-flutter/pull/309) ([ikurek](https://github.com/ikurek))

## [1.2.11](https://github.com/ably/ably-flutter/tree/v1.2.11)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.10...v1.2.11)

**Reverted Bug Fix:**

We made a change, released in [version 1.2.9](https://github.com/ably/ably-flutter/releases/tag/1.2.9), which we suspect has been causing issues for some customers.
This release reverts that change.

- Update to `ably-cocoa` v.1.2.10 [\#305](https://github.com/ably/ably-flutter/pull/305) ([QuintinWillison](https://github.com/QuintinWillison))

**Fixed bugs:**

- Customer reporting issue with NPE on Android push notifications [\#298](https://github.com/ably/ably-flutter/issues/298)

**Merged pull requests:**

- Checked for nullity of activation / deactivation results [\#303](https://github.com/ably/ably-flutter/pull/303) ([ikbalkaya](https://github.com/ikbalkaya))
- Correct the migration guide [\#301](https://github.com/ably/ably-flutter/pull/301) ([QuintinWillison](https://github.com/QuintinWillison))
- Add workaround for firebase messaging [\#289](https://github.com/ably/ably-flutter/pull/289) ([ikbalkaya](https://github.com/ikbalkaya))

## [1.2.10](https://github.com/ably/ably-flutter/tree/v1.2.10)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.9...v1.2.10)

**Bug Fix:**

This bug affects customers using
[message content encryption](https://ably.com/documentation/realtime/encryption)
alongisde
[channel history](https://ably.com/documentation/rest/history)
for a single Ably client instance.
It only affects the iOS runtime (not an issue on Android).
History REST requests, on iOS only, were incorrectly returning encrypted payloads,
despite encryption having been enabled via the Realtime channel `setOptions` API.

- **Bug**: Updating Realtime channel options doesn’t update the options of its REST counterpart [\#296](https://github.com/ably/ably-flutter/issues/296), caused by [ably/ably-cocoa\#1265](https://github.com/ably/ably-cocoa/issues/1265)
- **Fix**: Update to `ably-cocoa` v.1.2.9 [\#299](https://github.com/ably/ably-flutter/pull/299) ([QuintinWillison](https://github.com/QuintinWillison)), using [ably/ably-cocoa\#1266](https://github.com/ably/ably-cocoa/pull/1266) ([lawrence-forooghian](https://github.com/lawrence-forooghian))

## [1.2.9](https://github.com/ably/ably-flutter/tree/v1.2.9)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.8...v1.2.9)

**Bug Fixes:**

- Push device registration does not clear/reset device details on iOS [\#287](https://github.com/ably/ably-flutter/issues/287), fixed in [\#293](https://github.com/ably/ably-flutter/pull/293) ([QuintinWillison](https://github.com/QuintinWillison))
- Our PN broadcast receiver issue causes ANR on Android [\#290](https://github.com/ably/ably-flutter/issues/290), fixed in [\#291](https://github.com/ably/ably-flutter/pull/291) ([ikbalkaya](https://github.com/ikbalkaya))

## [1.2.8](https://github.com/ably/ably-flutter/tree/v1.2.8)

**Bug Fix:**
Push activation not completing on iOS when running in release configuration [\#276](https://github.com/ably/ably-flutter/issues/276),
fixed in [\#277](https://github.com/ably/ably-flutter/pull/277) ([ben-xD](https://github.com/ben-xD))

## [1.2.7](https://github.com/ably/ably-flutter/tree/v1.2.7)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.6...v1.2.7)

**Implemented enhancements:**

- Replace optional fields with default values [\#230](https://github.com/ably/ably-flutter/issues/230)
- Refactor example app to be more readable [\#212](https://github.com/ably/ably-flutter/issues/212)
- AuthCallback and InstanceStore Refactoring and documentation [\#250](https://github.com/ably/ably-flutter/pull/250) ([ben-xD](https://github.com/ben-xD))
- Serialize LogLevel using constants [\#244](https://github.com/ably/ably-flutter/pull/244) ([ben-xD](https://github.com/ben-xD))
- Replace deprecated method calls in tests [\#243](https://github.com/ably/ably-flutter/pull/243) ([ben-xD](https://github.com/ben-xD))
- Example app: Paginated results viewer widget [\#242](https://github.com/ably/ably-flutter/pull/242) ([ben-xD](https://github.com/ben-xD))
- Example app: Move out Realtime and Rest UI to separate widget and service [\#240](https://github.com/ably/ably-flutter/pull/240) ([ben-xD](https://github.com/ben-xD))
- Example app: Extract System Details sliver into new widget [\#239](https://github.com/ably/ably-flutter/pull/239) ([ben-xD](https://github.com/ben-xD))
- Hide API key secret inside API key UI [\#237](https://github.com/ably/ably-flutter/pull/237) ([ben-xD](https://github.com/ben-xD))
- Rename `pushSetOnBackgroundMessage` to `pushBackgroundFlutterApplicationReadyOnAndroid` [\#236](https://github.com/ably/ably-flutter/pull/236) ([ben-xD](https://github.com/ben-xD))
- Add default values to ClientOptions [\#233](https://github.com/ably/ably-flutter/pull/233) ([ben-xD](https://github.com/ben-xD))

**Fixed bugs:**

- Clear iOS platform instances synchronously [\#249](https://github.com/ably/ably-flutter/pull/249) ([ben-xD](https://github.com/ben-xD))

**Closed issues:**

- 1.2.6 java.lang.NullPointerException when stream fails to close [\#274](https://github.com/ably/ably-flutter/issues/274)
- 1.2.6 java.lang.NullPointerException when using token auth  [\#272](https://github.com/ably/ably-flutter/issues/272)
- `setMockMethodCallHandler` is deprecated. Use `tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler` instead [\#173](https://github.com/ably/ably-flutter/issues/173)

**Merged pull requests:**

- Rename inconsistent methods to be more consistent [\#248](https://github.com/ably/ably-flutter/pull/248) ([ben-xD](https://github.com/ben-xD))
- Use Objective-C standard style for LogLevel enum [\#246](https://github.com/ably/ably-flutter/pull/246) ([ben-xD](https://github.com/ben-xD))
- Platform encapsulation [\#235](https://github.com/ably/ably-flutter/pull/235) ([ben-xD](https://github.com/ben-xD))

## [1.2.6](https://github.com/ably/ably-flutter/tree/v1.2.6)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.5...v1.2.6)

**Implemented enhancements:**

- Make the symmetric encryption UI more usable [\#229](https://github.com/ably/ably-flutter/pull/229) ([ben-xD](https://github.com/ben-xD))
- Improve android logging: Remove unnecessary print statements, and use Log.w where necessary [\#228](https://github.com/ably/ably-flutter/pull/228) ([ben-xD](https://github.com/ben-xD))
- iOS: add `notification` in RemoteMessage [\#224](https://github.com/ably/ably-flutter/pull/224) ([ben-xD](https://github.com/ben-xD))
- Fix `setOptions` to complete the Future \(previously did not call `result.success`\) and remove side effects in example app [\#222](https://github.com/ably/ably-flutter/pull/222) ([ben-xD](https://github.com/ben-xD))

**Fixed bugs:**

- iOS push notifications error handling: Stop sending `FlutterError` through MethodChannel. It is not supported and crashes the app. [\#214](https://github.com/ably/ably-flutter/issues/214)
- Explicitly check types of tokenDetails, instead of using macro which … [\#256](https://github.com/ably/ably-flutter/pull/256) ([ben-xD](https://github.com/ben-xD))

**Merged pull requests:**

- Docs improvement for Android push notifications [\#227](https://github.com/ably/ably-flutter/pull/227) ([ben-xD](https://github.com/ben-xD))
- Reduce dart analysis warnings and hints and remove "Interface" classes \(e.g. `RealtimeInterface`\) [\#213](https://github.com/ably/ably-flutter/pull/213) ([ben-xD](https://github.com/ben-xD))
- Remove unnecessary abstract classes [\#193](https://github.com/ably/ably-flutter/pull/193) ([ben-xD](https://github.com/ben-xD))

## [1.2.5](https://github.com/ably/ably-flutter/tree/v1.2.5)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.4...v1.2.5)

**Implemented enhancements:**

- Enhancement/push UI improvement for debugging [\#218](https://github.com/ably/ably-flutter/pull/218) ([ben-xD](https://github.com/ben-xD))

**Fixed bugs:**

- Handle error cases on iOS correctly, and simplify code [\#221](https://github.com/ably/ably-flutter/pull/221) ([ben-xD](https://github.com/ben-xD))
- Fix app crashing when app is not yet started on some devices [\#215](https://github.com/ably/ably-flutter/pull/215) ([ben-xD](https://github.com/ben-xD))

## [1.2.4](https://github.com/ably/ably-flutter/tree/v1.2.4)

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.3...v1.2.4)

**Implemented enhancements:**

- Upgrade ably cocoa [\#209](https://github.com/ably/ably-flutter/pull/209) ([ben-xD](https://github.com/ben-xD))
- Symmetric encryption [\#192](https://github.com/ably/ably-flutter/pull/192) ([ben-xD](https://github.com/ben-xD))

**Fixed bugs:**

- Fix app crashing when receiving multiple push notifications [\#208](https://github.com/ably/ably-flutter/pull/208) ([ben-xD](https://github.com/ben-xD))

**Merged pull requests:**

- Update `flutter_local_notifications` to avoid bintray dependency resolution error [\#210](https://github.com/ably/ably-flutter/pull/210) ([ben-xD](https://github.com/ben-xD))
- Simplify state in example app [\#202](https://github.com/ably/ably-flutter/pull/202) ([ben-xD](https://github.com/ben-xD))

## [1.2.3](https://github.com/ably/ably-flutter/tree/v1.2.3)

This release lowers the minimum version of Flutter required to use Ably Flutter to 2.2.3.

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.2...v1.2.3)

**Merged pull requests:**

- Copy unawaited implementation into Ably Flutter to fix build failures for Flutter 2.2.3 [\#198](https://github.com/ably/ably-flutter/pull/198) ([ben-xD](https://github.com/ben-xD))

## [1.2.2](https://github.com/ably/ably-flutter/tree/v1.2.2)

This release adds support for push notifications, including device activation with Ably (including device registration with APNs / FCM), subscribing devices for push notifications and handling the push notifications in your Flutter application, without writing iOS or Android code. Check out the [push notifications documentation](PushNotifications.md) for more information. We also fixed some bugs that were either reported in Github issues or found internally.

[Full Changelog](https://github.com/ably/ably-flutter/compare/v1.2.1...v1.2.2)

**Implemented enhancements:**

- Update to latest ably-android version [\#147](https://github.com/ably/ably-flutter/issues/147)
- Implement Push Notifications listener [\#141](https://github.com/ably/ably-flutter/issues/141)
- Implement RSC7d \(Ably-Agent header\) [\#100](https://github.com/ably/ably-flutter/issues/100)
- Push Notifications Device Registration \(activation\) and device subscription [\#107](https://github.com/ably/ably-flutter/issues/107)

**Fixed bugs:**

- Remove timeouts for platform method calls [\#171](https://github.com/ably/ably-flutter/issues/171)
- Token Authentication with authCallback in Android: `java.lang.Exception: Invalid authCallback response` [\#156](https://github.com/ably/ably-flutter/issues/156)
- AuthCallback error: `java.lang.Exception: Invalid authCallback response` on Flutter Android [\#121](https://github.com/ably/ably-flutter/issues/121)

**Closed issues:**

- Can not set RealTimeChannelOptions params  [\#182](https://github.com/ably/ably-flutter/issues/182)
- java lang Invalid authCallback response [\#181](https://github.com/ably/ably-flutter/issues/181)
- Replace `package:pedantic` with `package:flutter_lints` [\#168](https://github.com/ably/ably-flutter/issues/168)
- Push Registrations cannot be updated on Android: fails with `No authentication information provided` [\#167](https://github.com/ably/ably-flutter/issues/167)
- Implement activation/ deactivation/ updating lifecycle method [\#154](https://github.com/ably/ably-flutter/issues/154)
- Connect to Ably Realtime using socket\_io\_client [\#148](https://github.com/ably/ably-flutter/issues/148)
- Failing Android build: `The plugin ably_flutter could not be built` URGENT [\#129](https://github.com/ably/ably-flutter/issues/129)
- Add support for symmetric encryption [\#127](https://github.com/ably/ably-flutter/issues/127)
- Lint rule to enforce strict raw types [\#85](https://github.com/ably/ably-flutter/issues/85)
- Add linting rules [\#30](https://github.com/ably/ably-flutter/issues/30)

**Merged pull requests:**

- Fix 2 Channel options bugs [\#191](https://github.com/ably/ably-flutter/pull/191) ([ben-xD](https://github.com/ben-xD))
- Fix RealtimeChannelOptions to avoid forcing cipher argument [\#190](https://github.com/ably/ably-flutter/pull/190) ([ben-xD](https://github.com/ben-xD))
- Refactoring: Move classes into separate files [\#189](https://github.com/ably/ably-flutter/pull/189) ([ben-xD](https://github.com/ben-xD))
- Add ably agent header [\#188](https://github.com/ably/ably-flutter/pull/188) ([ben-xD](https://github.com/ben-xD))
- Update Ably-cocoa dependency to 1.2.6 [\#186](https://github.com/ably/ably-flutter/pull/186) ([ben-xD](https://github.com/ben-xD))
- Bug fix: Reactivating devices for Push [\#185](https://github.com/ably/ably-flutter/pull/185) ([ben-xD](https://github.com/ben-xD))
- Push Notifications documentation enhancement [\#177](https://github.com/ably/ably-flutter/pull/177) ([ben-xD](https://github.com/ben-xD))
- Handle Push Notifications in Dart, including foreground messages, background messages and notification taps [\#166](https://github.com/ably/ably-flutter/pull/166) ([ben-xD](https://github.com/ben-xD))
- Fix `invalid authCallback response` when using token authentication [\#164](https://github.com/ably/ably-flutter/pull/164) ([ben-xD](https://github.com/ben-xD))
- Use image URLs instead of relative paths, and add note to `CONTRIBUTING.md` [\#163](https://github.com/ably/ably-flutter/pull/163) ([ben-xD](https://github.com/ben-xD))
- Clarify documentation about when device uses APNs production/ development device tokens [\#161](https://github.com/ably/ably-flutter/pull/161) ([ben-xD](https://github.com/ben-xD))
- Add documentation for token authentication [\#155](https://github.com/ably/ably-flutter/pull/155) ([ben-xD](https://github.com/ben-xD))
- Push notifications \(activation and subscription\) [\#140](https://github.com/ably/ably-flutter/pull/140) ([ben-xD](https://github.com/ben-xD))

## [1.2.2-preview.1](https://github.com/ably/ably-flutter/tree/v1.2.2-preview.1)

This is a preview release of v1.2.2, which adds support for push notifications, including device activation with Ably (including device registration with APNs / FCM) and subscribing devices for push notifications. Check out the dedicated documentation (`PushNotifications.md`) and the example app (`push_notification_service.dart`) for more information.

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
[Features Specification](https://docs.ably.com/client-lib-development-guide/features), also aligning with the
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
